import { Gdk, Gtk } from "ags/gtk4"
import { For } from "gnim"

import { services, type Workspace } from "../../services"
import { niri } from "../../services/niri"
import { pointerCursor } from "../common/cursor"

function WorkspaceButton({ workspace }: { workspace: Workspace }) {
  const stateClass = workspace.is_focused
    ? "workspace-focused"
    : workspace.is_active
      ? "workspace-active"
      : workspace.is_urgent
        ? "workspace-urgent"
        : ""

  return (
    <button
      {...pointerCursor}
      class={`workspace ${stateClass}`}
      widthRequest={16}
      heightRequest={16}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
      tooltipText={workspace.name || `Workspace ${workspace.idx}`}
      onClicked={() => niri.focusWorkspace(workspace.idx)}
    />
  )
}

export default function Workspaces({ monitor }: { monitor: Gdk.Monitor }) {
  const connector = monitor.get_connector() ?? ""
  return (
    <box class="workspaces" spacing={8}>
      <For
        each={services.workspaces((items) =>
          items
            .filter((workspace) => !connector || workspace.output === connector)
            .sort((left, right) => left.idx - right.idx),
        )}
      >
        {(workspace: Workspace) => <WorkspaceButton workspace={workspace} />}
      </For>
    </box>
  )
}
