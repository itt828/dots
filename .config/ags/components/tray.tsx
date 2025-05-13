import AstalTray from 'gi://AstalTray';
import { GObject, bind } from 'astal';
import { Gtk } from 'astal/gtk4';

export const Tray = () => {
	const tray = AstalTray.get_default();
	return (
		<box cssClasses={[]}>
			{bind(tray, 'items').as((items) =>
				items.map((item) => (
					<menubutton
						setup={(self) => {
							self.insert_action_group('dbusmenu', item.actionGroup);
						}}
						tooltipText={bind(item, 'tooltipMarkup')}
					>
						<image gicon={bind(item, 'gicon')} />
						{Gtk.PopoverMenu.new_from_model(item.menuModel)}
					</menubutton>
				)),
			)}
		</box>
	);
};
