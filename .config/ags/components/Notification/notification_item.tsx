import AstalNotifd from 'gi://AstalNotifd';
import { GLib } from 'astal';
import { Astal, Gtk } from 'astal/gtk4';
import type { EventBox } from 'astal/gtk4/widget';

const isIcon = (icon: string) => !!Astal.Icon.lookup_icon(icon);

const fileExists = (path: string) => GLib.file_test(path, GLib.FileTest.EXISTS);

const time = (time: number, format = '%H:%M') =>
	GLib.DateTime.new_from_unix_local(time).format(format)!;

const urgency = (n: AstalNotifd.Notification) => {
	const { LOW, NORMAL, CRITICAL } = AstalNotifd.Urgency;
	switch (n.urgency) {
		case LOW:
			return 'low';
		case CRITICAL:
			return 'critical';
		case NORMAL:
		default:
			return 'normal';
	}
};

type Props = {
	setup(self: EventBox): void;
	onHoverLost(self: EventBox): void;
	notification: AstalNotifd.Notification;
};

export default function Notification(props: Props) {
	const { notification: n, onHoverLost, setup } = props;
	const { START, CENTER, END } = Gtk.Align;

	return (
		<eventbox
			className={`Notification ${urgency}`}
			setup={setup}
			onHoverLost={onHoverLost}
		>
			<box vertical>
				<box className="header">
					{(n.appIcon || n.desktopEntry) && (
						<icon
							className="app-icon"
							visible={Boolean(n.appIcon || n.desktopEntry)}
							icon={n.appIcon || n.desktopEntry}
						/>
					)}
					<label className="time" hexpand halign={END} label={time(n.time)} />
					<button onClicked={() => n.dismiss()}>
						<icon icon="window-close-symbolic" />
					</button>
				</box>
				<Gtk.Separator visible />
				<box className="content">
					{n.image && fileExists(n.image) && (
						<box
							valign={START}
							className="image"
							css={`background-image: url('${n.image}')`}
						/>
					)}
				</box>
				{n.image && isIcon(n.image) && (
					<box expand={false} valign={START} className="icon-image">
						<icon icon={n.image} expand halign={CENTER} valign={CENTER} />
					</box>
				)}
				<box vertical>
					<label
						className="summary"
						halign={START}
						xalign={0}
						label={n.summary}
						truncate
					/>
					{n.body && (
						<label
							className="body"
							wrap
							useMarkup
							halign={START}
							xalign={0}
							justifyFill
							label={n.body}
						/>
					)}
				</box>
				{n.get_actions().length > 0 && (
					<box className="actions">
						{n.get_actions().map(({ label, id }) => (
							<button hexpand onClicked={() => n.invoke(id)}>
								<label label={label} halign={CENTER} hexpand />
							</button>
						))}
					</box>
				)}
			</box>
		</eventbox>
	);
}
