import { App, Astal, Gdk } from 'astal/gtk4';

export default function Dock(gdkmonitor: Gdk.Monitor) {
	const { TOP, LEFT, RIGHT, BOTTOM } = Astal.WindowAnchor;
	return (
		<window
			visible={false}
			cssClasses={[
				'mt-0',
				'mx-2',
				'px-3',
				'py-1',
				'rounded-b-8',
				'bg-[#d2b29488]',
			]}
			name="Dock"
			application={App}
			anchor={TOP | RIGHT | BOTTOM}
			layer={Astal.Layer.TOP}
			exclusivity={Astal.Exclusivity.IGNORE}
			onKeyPressed={(_, keyval) => {
				if (keyval === Gdk.KEY_Escape) {
					App.toggle_window("Dock");
				}
			}}
		>
			<label label={'Hi'} />
		</window>
	);
}
