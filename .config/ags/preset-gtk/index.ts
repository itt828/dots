import type { Preset, Rule } from 'unocss';
import { background } from './background';
import { sizing } from './sizing';
import { spacing } from './spacing';
import { type Theme, theme } from './theme';
import { typography } from './typography';
import { resolveColor, resolveSize } from './utils';
import { border } from './border';
import { variants } from './variant';

const handleText = (value: string, theme: { [key: string]: any }) => {
	const size = resolveSize(value, theme, 'fontSize');
	if (size) return { 'font-size': size };
	return { color: resolveColor(value, theme) };
};

const rules: Rule<Theme>[] = [
	...spacing,
	...sizing,
	...typography,
	...background,
	...border,
	// ...effect,
	// ...filter,
	// ...table,
	// ...animation,
	// ...transform,
	// ...interactivity,
	// ...gtk,
];

export const presetGtk = (): Preset<Theme> => ({
	name: 'unocss-preset-gtk',
	rules,
	theme,
	variants,
});
