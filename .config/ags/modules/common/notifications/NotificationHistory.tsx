import { Gtk } from "ags/gtk4"
import { For } from "gnim"

import { doNotDisturb, notificationService, notifications } from "../../../services"
import { pointerCursor } from "../cursor"

function NotificationItem({ notification }: { notification: any }) {
  return (
    <box class="notification-card" orientation={Gtk.Orientation.VERTICAL} spacing={5}>
      <box spacing={8}>
        <image
          visible={Boolean(notification.appIcon)}
          iconName={notification.appIcon || "dialog-information-symbolic"}
          pixelSize={20}
        />
        <label
          class="notification-app"
          xalign={0}
          hexpand
          label={notification.appName || "System"}
        />
        <button
          {...pointerCursor}
          class="action-button notification-close"
          onClicked={() => notification.dismiss()}
        >
          <label label="×" />
        </button>
      </box>
      <label class="notification-summary" xalign={0} wrap label={notification.summary || ""} />
      <label class="secondary" xalign={0} wrap label={notification.body || ""} />
      <box visible={notification.actions.length > 0} spacing={6}>
        {notification.actions.map((action: any) => (
          <button {...pointerCursor} class="action-button" onClicked={() => action.invoke()}>
            <label label={action.label} />
          </button>
        ))}
      </box>
    </box>
  )
}

export default function NotificationHistory() {
  return (
    <box class="page notification-history" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
      <box spacing={8}>
        <label class="section-title" xalign={0} hexpand label="Notifications" />
        <switch
          active={doNotDisturb}
          tooltipText="Do not disturb"
          onStateSet={(_, state) => {
            notificationService.dontDisturb = state
            return false
          }}
        />
        <button
          {...pointerCursor}
          class="action-button"
          onClicked={() =>
            notificationService.get_notifications().forEach((item: any) => item.dismiss())
          }
        >
          <label label="すべて消去" />
        </button>
      </box>
      <scrolledwindow vexpand minContentHeight={180} propagateNaturalHeight>
        <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
          <label
            visible={notifications((items: any[]) => items.length === 0)}
            class="secondary"
            label="No new notifications"
          />
          <For each={notifications}>
            {(notification) => <NotificationItem notification={notification} />}
          </For>
        </box>
      </scrolledwindow>
    </box>
  )
}
