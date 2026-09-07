import { execAsync, subprocess } from "ags/process"
import { timeout } from "ags/time"
import { createComputed, createState } from "gnim"

export type Workspace = {
  id: number
  idx: number
  name?: string
  output: string
  is_active: boolean
  is_focused: boolean
  is_urgent: boolean
  local_urgent?: boolean
  active_window_id?: number | null
}

export type NiriWindow = {
  id: number
  title?: string | null
  app_id?: string | null
  workspace_id?: number | null
  is_focused?: boolean
  is_urgent?: boolean
}

type WorkspaceActivated = { id: number; focused?: boolean }
type WorkspaceActiveWindowChanged = { workspace_id: number; active_window_id: number | null }
type WorkspaceUrgencyChanged = { id: number; urgent: boolean }
type WindowFocusChanged = { id: number | null }
type WindowUrgencyChanged = { id: number; urgent: boolean }

const [workspaces, setWorkspaces] = createState<Workspace[]>([])
const [windows, setWindows] = createState<NiriWindow[]>([])
const [focusedWindowId, setFocusedWindowId] = createState<number | null>(null)

const windowTitle = createComputed(() => {
  const id = focusedWindowId()
  return windows().find((window) => window.id === id)?.title ?? ""
})

function replaceWorkspaces(next: Workspace[]) {
  const current = workspaces()
  setWorkspaces(
    next.map((workspace) => {
      const previous = current.find((item) => item.id === workspace.id)
      const localUrgent = Boolean(previous?.local_urgent && !workspace.is_focused)
      return {
        ...workspace,
        is_urgent: workspace.is_urgent || localUrgent,
        local_urgent: localUrgent,
      }
    }),
  )
}

function activateWorkspace(event: WorkspaceActivated) {
  const target = workspaces().find((workspace) => workspace.id === event.id)
  if (!target) return

  setWorkspaces(
    workspaces().map((workspace) => {
      if (workspace.id === event.id) {
        return {
          ...workspace,
          is_active: true,
          is_focused: event.focused ?? workspace.is_focused,
          is_urgent: false,
          local_urgent: false,
        }
      }
      if (workspace.output === target.output) {
        return { ...workspace, is_active: false, is_focused: false }
      }
      if (event.focused && workspace.is_focused) return { ...workspace, is_focused: false }
      return workspace
    }),
  )
}

function setWorkspaceUrgency(id: number, urgent: boolean) {
  setWorkspaces(
    workspaces().map((workspace) =>
      workspace.id === id
        ? { ...workspace, is_urgent: urgent || Boolean(workspace.local_urgent) }
        : workspace,
    ),
  )
}

function setLocalWorkspaceUrgency(id: number) {
  setWorkspaces(
    workspaces().map((workspace) =>
      workspace.id === id ? { ...workspace, is_urgent: true, local_urgent: true } : workspace,
    ),
  )
}

function setWorkspaceActiveWindow(event: WorkspaceActiveWindowChanged) {
  setWorkspaces(
    workspaces().map((workspace) =>
      workspace.id === event.workspace_id
        ? { ...workspace, active_window_id: event.active_window_id }
        : workspace,
    ),
  )
}

function replaceWindows(next: NiriWindow[]) {
  setWindows(next)
  const focused = next.find((window) => window.is_focused)
  setFocusedWindowId(focused?.id ?? null)
}

function upsertWindow(window: NiriWindow) {
  const current = windows()
  const index = current.findIndex((item) => item.id === window.id)
  const previous = current[index]
  setWindows(
    index < 0
      ? [...current, window]
      : [...current.slice(0, index), window, ...current.slice(index + 1)],
  )
  if (window.is_focused) setFocusedWindowId(window.id)
  if (
    window.workspace_id &&
    !window.is_focused &&
    previous !== undefined &&
    previous.title !== window.title
  ) {
    setLocalWorkspaceUrgency(window.workspace_id)
  }
  if (window.workspace_id && window.is_urgent) setLocalWorkspaceUrgency(window.workspace_id)
}

function closeWindow(id: number) {
  setWindows(windows().filter((window) => window.id !== id))
  if (focusedWindowId() === id) setFocusedWindowId(null)
}

function focusWindow(event: WindowFocusChanged) {
  setFocusedWindowId(event.id)
  setWindows(windows().map((window) => ({ ...window, is_focused: window.id === event.id })))
}

function setWindowUrgency(event: WindowUrgencyChanged) {
  const next = windows().map((window) =>
    window.id === event.id ? { ...window, is_urgent: event.urgent } : window,
  )
  setWindows(next)

  const workspaceId = next.find((window) => window.id === event.id)?.workspace_id
  if (workspaceId) {
    setWorkspaceUrgency(
      workspaceId,
      next.some((window) => window.workspace_id === workspaceId && window.is_urgent),
    )
  }
}

function handleEvent(line: string) {
  if (!line.trim()) return

  try {
    const event = JSON.parse(line) as Record<string, any>
    if (event.WorkspacesChanged) replaceWorkspaces(event.WorkspacesChanged.workspaces ?? [])
    if (event.WorkspaceActivated) activateWorkspace(event.WorkspaceActivated)
    if (event.WorkspaceActiveWindowChanged) {
      setWorkspaceActiveWindow(event.WorkspaceActiveWindowChanged)
    }
    if (event.WorkspaceUrgencyChanged) {
      const data = event.WorkspaceUrgencyChanged as WorkspaceUrgencyChanged
      setWorkspaceUrgency(data.id, data.urgent)
    }
    if (event.WindowsChanged) replaceWindows(event.WindowsChanged.windows ?? [])
    if (event.WindowOpenedOrChanged) upsertWindow(event.WindowOpenedOrChanged.window)
    if (event.WindowClosed) closeWindow(event.WindowClosed.id)
    if (event.WindowFocusChanged) focusWindow(event.WindowFocusChanged)
    if (event.WindowUrgencyChanged) setWindowUrgency(event.WindowUrgencyChanged)
  } catch (error) {
    console.error(`Failed to parse niri event: ${line}`, error)
  }
}

function focusWorkspace(index: number) {
  execAsync(["niri", "msg", "action", "focus-workspace", String(index)]).catch((error) =>
    console.error(`Failed to focus niri workspace ${index}`, error),
  )
}

let restartTimer: ReturnType<typeof timeout> | undefined
let eventStream: ReturnType<typeof subprocess> | undefined

function startEventStream() {
  restartTimer?.cancel()
  try {
    eventStream = subprocess({
      cmd: ["stdbuf", "-oL", "niri", "msg", "-j", "event-stream"],
      out: handleEvent,
      err(error) {
        if (error) console.error(`niri event stream: ${error}`)
      },
    })
    eventStream.connect("exit", () => {
      eventStream = undefined
      restartTimer = timeout(1_000, startEventStream)
    })
  } catch (error) {
    console.error("Failed to start niri event stream", error)
    restartTimer = timeout(1_000, startEventStream)
  }
}

startEventStream()

export const niri = {
  workspaces,
  windows,
  windowTitle,
  focusWorkspace,
}
