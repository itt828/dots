import type { DynamicMatcher, Rule } from '@unocss/core';
import type { Theme } from './theme';
import { resolveSize } from './utils';

const propExpanded: Record<string, string> = {
	p: 'padding',
	m: 'margin',
};
const directionSuffixes: Record<string, string[]> = {
	'': [''],
	r: ['-right'],
	l: ['-left'],
	t: ['-top'],
	b: ['-bottom'],
	x: ['-right', '-left'],
	y: ['-top', '-bottom'],
};

const handleSpacing: DynamicMatcher<Theme> = ([, p, d, v], { theme }) => {
	const suffixes = directionSuffixes[d];
	const size = /^\d+$/.test(v)
		? `${Number(v) * 4}px`
		: resolveSize(v, theme, 'spacing');
	if (!size) return;

	const result: Record<string, string> = {};
	for (const suffix of suffixes) {
		const prop = `${propExpanded[p]}${suffix}`;
		result[prop] = size;
	}
	return result;
};

export const spacing: Rule<Theme>[] = [
	[/^([pm])([rltbxy]?)-(.+)$/, handleSpacing],
];
