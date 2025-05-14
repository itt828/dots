import { Variant } from 'unocss';
import { type Theme } from './theme';

const makeVariant = (name: string): Variant<Theme> => {
	return {
		name,
		match: (matcher) => {
			if (matcher.startsWith(`${name}:`)) {
				return {
					matcher: matcher.slice(name.length + 1),
					selector: (s) => `${s}:${name}`,
				};
			}
		},
	};
};

export const variants: Variant<Theme>[] = [
	// nth-child(n)
	// :nth-last-child(n)
	makeVariant('first-child'),
	makeVariant('last-child'),
	makeVariant('only-child'),
	makeVariant('link'),
	makeVariant('active'),
	makeVariant('hover'),
	makeVariant('focus'),
	makeVariant('focus-within'),
	makeVariant('focus-visible'),
	makeVariant('disabled'),
	makeVariant('checked'),
	makeVariant('indeterminate'),
	makeVariant('backdrop'),
	makeVariant('selected'),
	// :not(selector)
	// :dir(ltr)
	// :dir(rtl)
	// :drop(active)
	// :root
	// E F
	// E > F
	// E ~ F
	// E + F
];
