import { Variable } from 'astal';
const time = Variable('').poll(1000, "date '+%-m/%-d(%a) %H:%M:%S'");

export const Clock = () => {
	return (
		<box cssClasses={['text-white']}>
			<label label={time()} />
		</box>
	);
};
