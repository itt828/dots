import { Astal, Gdk, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"
import Graphene from "gi://Graphene"
import { createState } from "gnim"

import { pointerCursor } from "../cursor"
import { phosphor } from "../icons"
import NotificationHistory from "../notifications/NotificationHistory"
import { toggleWindow } from "../windows"
import AudioPage from "./AudioPage"
import BluetoothPage from "./BluetoothPage"
import ControlCenterHome from "./ControlCenterHome"
import NetworkPage from "./NetworkPage"
import ToolsPage from "./ToolsPage"

export default function Dashboard(gdkmonitor: Gdk.Monitor) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
  let window: Gtk.Window
  let content: Gtk.Box
  let pages: Gtk.Stack
  const [currentPage, setCurrentPage] = createState("home")

  function closeOutside(_gesture: Gtk.GestureClick, _presses: number, x: number, y: number) {
    const [, bounds] = content.compute_bounds(window)
    if (!bounds.contains_point(new Graphene.Point({ x, y }))) window.visible = false
  }

  return (
    <window
      $={(self: Gtk.Window) => (window = self)}
      name="dashboard"
      class="Dashboard"
      visible={false}
      gdkmonitor={gdkmonitor}
      application={app}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      layer={Astal.Layer.TOP}
      keymode={Astal.Keymode.ON_DEMAND}
      exclusivity={Astal.Exclusivity.IGNORE}
    >
      <Gtk.GestureClick onPressed={closeOutside} />
      <box
        $={(self) => (content = self as Gtk.Box)}
        class="dashboard-shell"
        orientation={Gtk.Orientation.VERTICAL}
        spacing={12}
        halign={Gtk.Align.CENTER}
        valign={Gtk.Align.START}
      >
        <box class="dashboard-header" spacing={8}>
          <box orientation={Gtk.Orientation.VERTICAL} hexpand>
            <label class="text-20 font-bold" xalign={0} label="Control Center" />
            <label class="secondary" xalign={0} label="クイック設定とシステム情報" />
          </box>
          <button
            {...pointerCursor}
            class="action-button icon-button"
            onClicked={() => toggleWindow("dashboard")}
          >
            <label class="font-phosphor" label={phosphor.x} />
          </button>
        </box>
        <scrolledwindow minContentHeight={510} maxContentHeight={510}>
          <stack
            $={(self) => (pages = self as Gtk.Stack)}
            name="pages"
            transitionType={Gtk.StackTransitionType.SLIDE_LEFT_RIGHT}
          >
            <box $type="named" name="home">
              <ControlCenterHome />
            </box>
            <box $type="named" name="notifications">
              <NotificationHistory />
            </box>
            <box $type="named" name="audio">
              <AudioPage />
            </box>
            <box $type="named" name="network">
              <NetworkPage />
            </box>
            <box $type="named" name="bluetooth">
              <BluetoothPage />
            </box>
            <box $type="named" name="tools">
              <ToolsPage />
            </box>
          </stack>
        </scrolledwindow>
        <box class="dashboard-nav" homogeneous spacing={6}>
          {[
            ["home", "Home"],
            ["notifications", "通知"],
            ["audio", "音声"],
            ["network", "Wi-Fi"],
            ["bluetooth", "BT"],
            ["tools", "Tools"],
          ].map(([page, label]) => (
            <button
              {...pointerCursor}
              class={currentPage(
                (current) =>
                  `dashboard-nav-button ${current === page ? "dashboard-nav-active" : ""}`,
              )}
              onClicked={() => {
                pages.visibleChildName = page
                setCurrentPage(page)
              }}
            >
              <label label={label} />
            </button>
          ))}
        </box>
      </box>
    </window>
  )
}
