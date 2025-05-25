// import AstalRiver from 'gi://AstalRiver';
import { App, type Gtk } from 'astal/gtk4';
import { exec } from 'astal/process';
import Bar from './widget/Bar';

exec('bunx unocss **/*.tsx -o /tmp/ags-uno.css');
const style = exec('cat /tmp/ags-uno.css');

App.start({
	css: style,
	main() {
		const bars = new Map<string, Gtk.Widget>();
		// const river = AstalRiver.get_default()!;

		App.get_monitors().map((v) => {
			bars.set(v.connector, Bar(v, v.connector == 'eDP-1'));
		});

		// river.connect('output-added', async (_, output) => {
		// 	await new Promise((r) => setTimeout(r, 1000));

		// 	const current_monitors = App.get_monitors();
		// 	const added_monitor = current_monitors.filter(
		// 		(v) => v.connector === output,
		// 	)[0];
		// 	if (added_monitor)
		// 		bars.set(output, Bar(added_monitor, output === 'eDP-1'));
		// });
		// river.connect('output-removed', (_, output) => {
		// 	bars.get(output)?.run_dispose();
		// 	bars.delete(output);
		// });
	},
});
