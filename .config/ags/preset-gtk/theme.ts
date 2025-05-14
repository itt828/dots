import { theme as wind4Theme } from 'unocss/preset-wind4';

export const theme = {
	colors: {
		...wind4Theme.colors,
	},
	spacing: {
		...wind4Theme.spacing,
	},
	fontSize: {},
};

export type Theme = typeof theme;
