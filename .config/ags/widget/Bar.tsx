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
			cssClasses={[
				'mt-0',
				'mx-2',
				'px-3',
				'py-0',
				'rounded-b-6',
				'bg-[#bcdbcd]',
			]}
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
					// <box>{/* <Output connector={gdkmonitor.connector} /> */}</box>
					<box>
					{/*
    					<button onClicked={()=>App.toggle_window("Dock")}>
                            <label label="ああ"/>
    				    </button>
				    */}
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
