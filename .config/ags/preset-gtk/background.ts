import type { DynamicMatcher, Rule } from '@unocss/core';
import type { Theme } from './theme';
import { resolveColor } from './utils';

const handleBackgroundClip: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleBackgroundColor: DynamicMatcher<Theme> = ([, v], { theme }) => {
	const color = resolveColor(v, theme);
	if (!color) return;
	return {
		'background-color': color,
	};
	return undefined;
};
const handleBackgroundImage: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};

export const background: Rule<Theme>[] = [
	[/^bg-clip-(border|padding|content|text)$/, handleBackgroundClip],
	[/^bg-(.+)$/, handleBackgroundColor],
	[/^bg-$/, handleBackgroundImage],
];
