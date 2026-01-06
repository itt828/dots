import { App, type Gtk } from 'astal/gtk4';
import { exec } from 'astal/process';
import Bar from './widget/Bar';
import Dock from './widget/Dock';

exec('bunx unocss **/*.tsx -o /tmp/ags-uno.css');
const style = exec('cat /tmp/ags-uno.css');

App.start({
	css: style,
	main() {
		const bars = new Map<string, Gtk.Widget>();
		App.get_monitors().map((v) => {
			// if (v.connector === 'eDP-1')
				bars.set(v.connector, Bar(v, v.connector === 'eDP-1'));
		});
		App.get_monitors().map(Dock)
	},
});
