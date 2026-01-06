import { presetGtk } from '@itt/unocss-preset-gtk';
import { defineConfig } from 'unocss';

export default defineConfig({
	presets: [presetGtk()],
	shortcuts: {
		bx: 'bg-[#f9f2f2aa] rounded-3 mx-2 mt-2 py-1 px-4',
	},
	rules: [],
	preflights: [
		{
			getCSS: () => `
            * {
                color: #434343;
                font-family: "M PLUS 1";
                font-weight: 500;
            }
            `,
		},
	],
});
