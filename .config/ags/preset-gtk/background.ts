import type { DynamicMatcher, Rule } from '@unocss/core';
import type { Theme } from './theme';
import { resolveSize } from './utils';

const propExpand: Record<string, string> = {
	w: 'width',
	h: 'height',
};

const handleSizing: DynamicMatcher<Theme> = ([, p, v], { theme }) => {
	let size;
	if (/^\d+$/.test(v)) {
		size = `${Number(v) * 4}px`;
	} else if (/^((min|max|fit)-content|auto)$/.test(v)) {
		size = v;
	} else {
		size = resolveSize(v, theme, 'container');
	}
	if (!size) return;

	const result: Record<string, string> = {};
	const prop = `min-${propExpand[p]}`;
	result[prop] = size;
	return result;
};

const handleBackgroundClip: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleBackgroundColor: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleBackgroundImage: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};

export const background: Rule<Theme>[] = [
	[/^bg-clip-(border|padding|content|text)$/, handleBackgroundClip],
	[/^bg-$/, handleBackgroundColor],
	[/^bg-$/, handleBackgroundImage],
];
