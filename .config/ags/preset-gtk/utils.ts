export const resolveColor = (value: string, theme: { [key: string]: any }) => {
	if (value.startsWith('[') && value.endsWith(']')) {
		const s = value.substring(1, value.length - 1).replaceAll('_', ' ');
		if (
			/^(#[\da-fA-F]{3,8})$/.test(s) ||
			/^(rgba?|hsl|hwb|oklab|oklch|color|color-mix)\(.*\)$/.test(s) ||
			/^[a-zA-Z]+$/.test(s)
		) {
			return s;
		}
	} else if (theme && theme.colors) {
		const parts = value.split('-');
		let current = theme.colors;
		for (const part of parts) {
			if (current && typeof current === 'object' && part in current) {
				current = current[part];
			} else {
				current = undefined;
				break;
			}
		}
		if (typeof current === 'string') {
			return current;
		}
	}
	if (/^[a-zA-Z]+$/.test(value)) {
		return value;
	}

	return undefined;
};

export const resolveSize = (
	value: string,
	theme: { [key: string]: any },
	key: string,
) => {
	if (value.startsWith('[') && value.endsWith(']')) {
		const s = value.substring(1, value.length - 1).replaceAll('_', ' ');
		if (
			/^[\d.-]+(px|pt|em|ex|rem|pc|in|cm|mm|%)?$/.test(s) ||
			s.startsWith('calc(')
		) {
			return s;
		}
	} else if (theme && theme[key]) {
		const parts = value.split('-');
		let current = theme[key];
		for (const part of parts) {
			if (current && typeof current === 'object' && part in current) {
				current = current[part];
			} else {
				current = undefined;
				break;
			}
		}
		if (typeof current === 'string') {
			return current;
		}
	}
	return undefined;
};
