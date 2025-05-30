import { App, Astal, type Gdk } from 'astal/gtk4';
import { Audio } from '../components/Audio';
import { Battery } from '../components/Battery';
import { Clock } from '../components/Clock';
import { Network } from '../components/Network';
import { Brightness } from '../components/brightness';
// import { Monitor } from '../components/monitor';
// import { Output } from '../components/river/Output';
import { Tray } from '../components/tray';
import { bind } from 'astal';

export default function Bar(gdkmonitor: Gdk.Monitor, isPrimary: boolean) {
	const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;
	return (
		<window
			visible
			cssClasses={['mt-2', 'mx-2']}
			application={App}
			gdkmonitor={gdkmonitor}
			anchor={TOP | LEFT | RIGHT}
			exclusivity={Astal.Exclusivity.EXCLUSIVE}
		>
			<centerbox>
				<box spacing={32}>
					<Clock />
					<Battery />
					<Network />
					<Audio />
					<Brightness />
					{/* <Monitor gdkmonitor={gdkmonitor} /> */}
				</box>
				{isPrimary ? (
					<box>
						{/* <Output connector={gdkmonitor.connector} /> */}
						<label label={bind(App, 'monitors').as((v) => String(v.length))} />
					</box>
				) : (
					<label />
				)}
				{isPrimary ? (
					<box>
						<Tray />
					</box>
				) : (
					<label />
				)}
			</centerbox>
		</window>
	);
}
