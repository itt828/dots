export default function EventSnack(
	gdkmonitor: Gdk.Monitor,
	isPrimary: boolean,
) {
	const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;
	return (
		<box
			visible
			cssClasses={[]}
			application={App}
			gdkmonitor={gdkmonitor}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
		></box>
	);
}
