import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"
import { type Accessor } from "gnim"

import {
  doNotDisturb,
  notificationService,
  notifications,
  run,
  services,
  setBrightness,
  setMicrophoneVolume,
  setVolume,
} from "../../../services"
import { pointerCursor } from "../cursor"
import { phosphor } from "../icons"
import MediaCard from "./MediaCard"

function QuickSetting({
  icon,
  title,
  subtitle,
  active,
  onClicked,
}: {
  icon: string
  title: string
  subtitle: Accessor<string>
  active: Accessor<boolean>
  onClicked: () => void
}) {
  return (
    <button
      {...pointerCursor}
      class={active((enabled) => `quick-setting ${enabled ? "quick-setting-active" : ""}`)}
      onClicked={onClicked}
    >
      <box spacing={10}>
        <label class="quick-setting-icon font-phosphor" label={icon} />
        <box orientation={Gtk.Orientation.VERTICAL} hexpand>
          <label class="card-title" xalign={0} label={title} />
          <label class="quick-setting-subtitle" xalign={0} ellipsize={3} label={subtitle} />
        </box>
      </box>
    </button>
  )
}

function ProfileCard() {
  const username = GLib.get_real_name() || GLib.get_user_name()
  const initial = Array.from(username)[0]?.toUpperCase() || "U"

  return (
    <box class="profile-card" spacing={12}>
      <label class="profile-avatar" label={initial} />
      <box orientation={Gtk.Orientation.VERTICAL} hexpand>
        <label class="profile-name" xalign={0} label={username} />
        <label
          class="secondary"
          xalign={0}
          label={services.time((date) =>
            date.toLocaleDateString("ja-JP", {
              weekday: "long",
              month: "long",
              day: "numeric",
            }),
          )}
        />
      </box>
      <label
        class="profile-time"
        label={services.time((date) =>
          date.toLocaleTimeString("ja-JP", { hour: "2-digit", minute: "2-digit" }),
        )}
      />
    </box>
  )
}

function QuickSettingsCard() {
  const bluetooth = createPoll(false, 2_000, async () => {
    try {
      return (await execAsync(["rfkill", "list", "bluetooth"])).includes("Soft blocked: no")
    } catch {
      return false
    }
  })

  return (
    <box class="quick-settings-grid" homogeneous spacing={8}>
      <QuickSetting
        icon={phosphor.wifiHigh}
        title="Wi-Fi"
        subtitle={services.network((state) => state.name)}
        active={services.network((state) => state.enabled)}
        onClicked={() =>
          run(["nmcli", "radio", "wifi", services.network.peek().enabled ? "off" : "on"])
        }
      />
      <QuickSetting
        icon={phosphor.network}
        title="Bluetooth"
        subtitle={bluetooth((enabled) => (enabled ? "オン" : "オフ"))}
        active={bluetooth}
        onClicked={() => run(["rfkill", bluetooth.peek() ? "block" : "unblock", "bluetooth"])}
      />
      <QuickSetting
        icon={phosphor.bellSlash}
        title="通知を停止"
        subtitle={notifications((items) => `${items.length}件の通知`)}
        active={doNotDisturb}
        onClicked={() => (notificationService.dontDisturb = !doNotDisturb.peek())}
      />
    </box>
  )
}

function SliderRow({
  icon,
  value,
  onChange,
}: {
  icon: string
  value: Accessor<number>
  onChange: (value: number) => void
}) {
  return (
    <box class="control-center-slider" spacing={10}>
      <label class="control-icon font-phosphor" label={icon} />
      <slider hexpand value={value} onValueChanged={(slider: any) => onChange(slider.value)} />
      <label class="value" label={value((current) => `${Math.round(current * 100)}%`)} />
    </box>
  )
}

function ControlsCard() {
  return (
    <box class="control-center-card" orientation={Gtk.Orientation.VERTICAL} spacing={10}>
      <SliderRow
        icon={phosphor.volumeHigh}
        value={services.volume((state) => state.volume)}
        onChange={setVolume}
      />
      <SliderRow
        icon={phosphor.microphone}
        value={services.microphone((state) => state.volume)}
        onChange={setMicrophoneVolume}
      />
      <SliderRow icon={phosphor.sunDim} value={services.brightness} onChange={setBrightness} />
    </box>
  )
}

function SystemCard() {
  return (
    <box class="system-card" homogeneous spacing={8}>
      <box spacing={8}>
        <label class="control-icon font-phosphor" label={phosphor.cpu} />
        <box orientation={Gtk.Orientation.VERTICAL}>
          <label class="secondary" xalign={0} label="Load" />
          <label class="card-title" xalign={0} label={services.cpu} />
        </box>
      </box>
      <box spacing={8}>
        <label class="control-icon font-phosphor" label={phosphor.ram} />
        <box orientation={Gtk.Orientation.VERTICAL}>
          <label class="secondary" xalign={0} label="Memory" />
          <label class="card-title" xalign={0} label={services.memory} />
        </box>
      </box>
    </box>
  )
}

export default function ControlCenterHome() {
  return (
    <box orientation={Gtk.Orientation.VERTICAL} spacing={10}>
      <ProfileCard />
      <QuickSettingsCard />
      <ControlsCard />
      <MediaCard />
      <SystemCard />
    </box>
  )
}
