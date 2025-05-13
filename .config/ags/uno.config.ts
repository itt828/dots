import { defineConfig, presetWind4 } from 'unocss';
import { presetGtk } from './preset-gtk';

export default defineConfig({
	presets: [
		presetWind4({
			arbitraryVariants: false,
			preflights: {
				reset: false,
			},
		}),
	],
	shortcuts: {
		bx: 'bg-[#f9f2f2aa] rounded-3 mx-2 mt-2 py-1 px-4',
	},
	rules: [],
	preflights: [
		{
			getCSS: () => `
            * {
                color: #555555;
                font-family: "M PLUS 1";
                font-weight: 500;
            }
            `,
		},
	],
});
