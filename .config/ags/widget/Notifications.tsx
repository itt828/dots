import AstalNotifd from 'gi://AstalNotifd';
import { Variable, bind, timeout } from 'astal';
import type { Subscribable } from 'astal/binding';
import { App, Astal, type Gdk, type Gtk } from 'astal/gtk4';
import Notification from '../components/Notification/notification_item';

class NotificationMap implements Subscribable {
	private map: Map<number, Gtk.Widget> = new Map();
	private var: Variable<Array<Gtk.Widget>> = Variable([]);
	private notify() {
		this.var.set([...this.map.values()].reverse());
	}
	constructor() {
		const notifd = AstalNotifd.get_default();
		notifd.connect('notified', (_, id) => {
			this.set(
				id,
				Notification({
					notification: notifd.get_notification(id)!,
					onHoverLost: () => this.delete(id),
					setup: () =>
						timeout(5000, () => {
							// this.delete(id)
						}),
				}),
			);
		});

		notifd.connect('resolved', (_, id) => {
			this.delete(id);
		});
	}
	private set(key: number, value: Gtk.Widget) {
		this.map.get(key)?.destroy();
		this.map.set(key, value);
		this.notify();
	}
	get() {
		return this.var.get();
	}
	subscribe(callback: (list: Array<Gtk.Widget>) => void): () => void {
		return this.var.subscribe(callback);
	}
}

export default function NotificationPopups(gdkmonitor: Gdk.Monitor) {
	const { TOP, RIGHT } = Astal.WindowAnchor;
	const notifs = new NotificationMap();
	return (
		<window
			className="NotificationPopups"
			gdkmonitor={gdkmonitor}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
			anchor={TOP | RIGHT}
		>
			<box vertical noImplicitDestroy>
				{bind(notifs)}
			</box>
		</window>
	);
}
