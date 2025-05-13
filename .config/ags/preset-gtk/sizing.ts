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

export const sizing: Rule<Theme>[] = [[/^min-(w|h)-(.+)$/, handleSizing]];
