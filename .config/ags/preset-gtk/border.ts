import type { DynamicMatcher, Rule } from '@unocss/core';
import type { Theme } from './theme';
import { resolveColor, resolveSize } from './utils';

const cornerSuffixes: Record<string, string[]> = {
	'': [''],
	s: ['-start-start', '-end-start'],
	e: ['-start-end', '-end-end'],
	t: ['-top-left', '-top-right'],
	r: ['-top-right', '-bottom-right'],
	b: ['-bottom-right', '-bottom-left'],
	l: ['-top-left', '-bottom-left'],
	ss: ['-start-start'],
	se: ['-start-end'],
	ee: ['-end-end'],
	es: ['-end-start'],
	tl: ['-top-left'],
	tr: ['-top-right'],
	br: ['-bottom-right'],
	bl: ['-bottom-left'],
};

const directionSuffix: Record<string, string> = {
	'': '',
	x: '-inline',
	y: '-block',
	s: '-inline-start',
	e: '-inline-end',
	t: '-top',
	r: '-right',
	b: '-bottom',
	l: '-left',
};
const handleBorderRadius: DynamicMatcher<Theme> = (
	[, c = '', v],
	{ theme },
) => {
	const size = /^\d+$/.test(v)
		? `${Number(v)}px`
		: v === 'full'
			? '9999px'
			: v === 'none'
				? '0'
				: resolveSize(v, theme, 'radius');
	if (!size) return;

	const result: Record<string, string> = {};
	for (const suffix of cornerSuffixes[c]) {
		const prop = `border${suffix}-radius`;
		result[prop] = size;
	}
	return result;
};

const handleBorderWidth: DynamicMatcher<Theme> = ([, d = '', v], { theme }) => {
	const size = /^\d+$/.test(v)
		? `${Number(v)}px`
		: resolveSize(v, theme, 'border');
	if (!size) return;
	const result: Record<string, string> = {};
	result[`border${directionSuffix[d]}-width`] = size;
	return result;
};
const handleBorderColor: DynamicMatcher<Theme> = ([, d = '', v], { theme }) => {
	const color = resolveColor(v, theme);
	if (!color) return;
	const result: Record<string, string> = {};
	result[`border${directionSuffix[d]}-color`] = color;
	return result;
};
const handleBorderStyle: DynamicMatcher<Theme> = ([, d = '', v], {}) => {
	const result: Record<string, string> = {};
	result[`border${directionSuffix[d]}-style`] = v;
	return result;
};

export const border: Rule<Theme>[] = [
	[/^rounded-(?:([setrbl]|[se]{2}|[tb][lr])-|)(.+)$/, handleBorderRadius],
	[/^border-(?:([xysetrbl])-|)(.+)$/, handleBorderWidth],
	[/^border-(?:([xysetrbl])-|)(.+)$/, handleBorderColor],
	[
		/^border-(?:([setrbl])-|)(solid|dashed|dotted|double|hidden|none)$/,
		handleBorderStyle,
	],
	// outline
];
