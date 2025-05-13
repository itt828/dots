import AstalRiver from 'gi://AstalRiver';
import { bind } from 'astal';
import { Gdk, Gtk } from 'astal/gtk4';

// 今のワークスペース, ウィンドウのあるワークスペース
// タイリングのmain/sub数、上下左右
// 注目モニター
// kanshi
// タブレット入力モニター切り替え

const Displays = () => {
	const river = AstalRiver.River.get_default();
	const { START, CENTER } = Gtk.Align;
	if (!river) {
		return <label label="River not found." />;
	}
	const outputs = bind(river, 'outputs');

	return (
		<box vertical valign={START}>
			{outputs.get().map((v) => (
				<label label={`${v.name}: ${v.focusedView}:${v.focused_tags}`} />
			))}
		</box>
	);
};

const Views = () => {
	const river = AstalRiver.River.get_default();
};

const TagButtons = ({ outputName }: { outputName: string }) => {
	const river = AstalRiver.River.get_default();
	if (!river) {
		return <label label="River not found." />;
	}
	const output = river.get_output(outputName)!;
	return (
		<box>
			<label label={outputName} />
			<label
				label={bind(output, 'focused_tags')
					.as((v) => String(v))
					.get()}
			/>
			{new Array(3).fill(null).map((_, i) => {
				return (
					<button
						label={`${i}`}
						onClick={() => (output.focused_tags = 1 << i)}
					/>
				);
			})}
		</box>
	);
};

export const Workspaces = () => {
	const river = AstalRiver.River.get_default();
	if (!river) return;
	const outputs = bind(river, 'outputs');

	return (
		<box className="River">
			{outputs.as((v) =>
				v.map((v) => {
					return <TagButtons outputName={v.name} />;
				}),
			)}
		</box>
	);
};
