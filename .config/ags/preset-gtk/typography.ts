import type { DynamicMatcher, Rule } from '@unocss/core';
import type { Theme } from './theme';
import { resolveColor, resolveSize } from './utils';

const handleFontFamily: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleFontWeight: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleFontSize: DynamicMatcher<Theme> = ([, v], { theme }) => {
	const size = resolveSize(v, theme, 'fontSize');
	if (!size) return;
	return {
		'font-size': size,
	};
};
const handleColor: DynamicMatcher<Theme> = ([, v], { theme }) => {
	const color = resolveColor(v, theme);
	if (!color) return;
	return {
		color: color,
	};
};
const handleFontStyle: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleFontStretch: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleFontVariantNumeric: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleLetterSpacing: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleLineHeight: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleTextDecorationLine: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleTextDecorationColor: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleTextDecorationStyle: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};
const handleTextTransform: DynamicMatcher<Theme> = ([,], { theme }) => {
	return undefined;
};

export const typography: Rule<Theme>[] = [
	// [/^font-(thin|extralight|light|...)^$/, handleFontFamily],
	// [/^font-^$/, handleFontWeight],
	[/^text-(.+)$/, handleFontSize],
	[/^text-(.+)$/, handleColor],
	// [/^(italic|non-italic)^$/, handleFontStyle],
	// [/^font-stretch-^$/, handleFontStretch],
	// [/^(normal-nums|ordinal|...)^$/, handleFontVariantNumeric],
	// [/^tracking-^$/, handleLetterSpacing],
	// [/^leading-^$/, handleLineHeight],
	// [
	// 	/^(underline|overline|line-througth|no-underline)$/,
	// 	handleTextDecorationLine,
	// ],
	// [/^decoration-$/, handleTextDecorationColor],
	// [/^decoration-$/, handleTextDecorationStyle],
	// [/^(uppercase|lowercase|capitalize|normal-case)$/, handleTextTransform],
];
