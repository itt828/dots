import type { Preset } from 'unocss'

// basic types
const size = ['px', 'pt', 'em', 'ex', 'rem', 'pc', 'in', 'cm', 'mm']
const percentage = ['%']
const angle = ['deg', 'rad', 'grad', 'turn']
const time = ['s', 'ms']
const numericSuffix = [...size, ...percentage, ...angle, ...time]
const numericRegex = new RegExp(`^([\\d.-]+)((${numericSuffix.join('|')})?)$`)

const colorValueExtractor = (value: string, theme: { [key: string]: any }): string => {
    console.log(value)
    const colorRegex = /^\[(#?[\da-fA-F]{3,8}|(?:rgba?|hsl|hwb|oklab|oklch|color|color-mix)\([^)]+\))\]$/
    if (theme.colors && theme.colors[value]) {
        return theme.colors[value]
    }
    else if (value.startsWith('@'))
        return `var(--${value.substring(1)})`
    else if (colorRegex.test(value)) {
        const [, v] = value.match(colorRegex)!
        return v
    }
    else
        return value
}

const sizeValueExtractor = (value: string, defaultUnit = "px"): string | number | undefined => {
    const match = value.match(numericRegex)
    if (match) {
        const [, num, , unit] = match
        if (unit) {
            return `${num}${unit}`
        }
        if (!isNaN(parseFloat(num))) {
            return `${parseFloat(num) * 4}${defaultUnit}`
        }
    }
    if (['auto', 'inherit', 'initial', 'unset', 'none', 'small', 'medium', 'large', 'fill', 'available', 'min-content', 'max-content', 'fit-content'].includes(value)) {
        return value
    }
    // 数値のみの場合 (例: line-height: 1.5)
    if (!isNaN(parseFloat(value))) {
        return parseFloat(value);
    }
    return undefined // または value をそのまま返す (キーワード等のため)
}

export const presetGtk = (): Preset => ({
    name: 'unocss-preset-gtk',
    rules: [
        [/^text-(.+)$/, ([, c], { theme }) => { return { color: colorValueExtractor(c, theme) } }],
        [/^opacity-(\d{1,3})$/, ([, d]) => ({ opacity: parseFloat(d) / 100 })],
        // filter
        [/^text-(.+)$/, ([, s]) => ({ 'font-size': sizeValueExtractor(s) })],
        [/^font-(italic|normal|oblique)$/, ([, s]) => ({ 'font-style': s })],
        // font-variant
        [/^font-(thin|extralight|light|normal|medium|semibold|bold|extrabold|black|[\d]{3})$/, ([, w]) => ({ 'font-weight': w })],
        // font-stretch
        // font-kerning
        // font-variant-ligatures
        // font-variant-caps
        // font-variant-numeric
        // font-variant-alternatives
        // font-variant-east-asian
        // font-feature-settings
        // font-variation-settings
        // -gtk-dpi
        // font
        [/^caret-(.+)$/, ([, c], { theme }) => ({ 'caret-color': colorValueExtractor(c, theme) })],
        // -gtk-secondary-caret-color
        // letter-spacing
        // text-transform
        [/^leading-(.+)$/, ([, s]) => ({ 'line-height': sizeValueExtractor(s, '') })],
        [/^decoration-(underline|overline|line-through|none)$/, ([, val]) => ({ 'text-decoration-line': val })],
        [/^decoration-c-(.+)$/, ([, c], { theme }) => ({ 'text-decoration-color': colorValueExtractor(c, theme) })],
        [/^decoration-(solid|double|dotted|dashed|wavy)$/, ([, val]) => ({ 'text-decoration-style': val })],
        [/^decoration-(.+)$/, ([, val]) => ({ 'text-decoration-thickness': sizeValueExtractor(val) })],
        // text-shadow
        [/^-gtk-icon-source-(.+)$/, ([, s]) => ({ '-gtk-icon-source': s })],
        [/^-gtk-icon-size-(.+)$/, ([, s]) => ({ '-gtk-icon-size': sizeValueExtractor(s) })],
        [/^-gtk-icon-style-(.+)$/, ([, s]) => ({ '-gtk-icon-style': s })],
        [/^-gtk-icon-transform-(.+)$/, ([, s]) => ({ '-gtk-icon-transform': s.replace(/_/g, ' ') })],
        [/^-gtk-icon-palette-(.+)$/, ([, c], { theme }) => ({ '--gtk-icon-palette': colorValueExtractor(c, theme) })],
        // -gtk-icon-shadow
        // -gtk-icon-filter
        // transform
        // transform-origin
        [/^(min-w)-(.+)$/, ([, attr, val]) => ({ [attr.replace('w', 'width')]: sizeValueExtractor(val) })],
        [/^(min-h)-(.+)$/, ([, attr, val]) => ({ [attr.replace('h', 'height')]: sizeValueExtractor(val) })],
        [/^m-([^-]+)$/, ([, s]) => ({ margin: sizeValueExtractor(s) })],
        [/^mt-([^-]+)$/, ([, s]) => ({ 'margin-top': sizeValueExtractor(s) })],
        [/^mr-([^-]+)$/, ([, s]) => ({ 'margin-right': sizeValueExtractor(s) })],
        [/^mb-([^-]+)$/, ([, s]) => ({ 'margin-bottom': sizeValueExtractor(s) })],
        [/^ml-([^-]+)$/, ([, s]) => ({ 'margin-left': sizeValueExtractor(s) })],
        [/^mx-([^-]+)$/, ([, s]) => { const v = sizeValueExtractor(s); return { 'margin-left': v, 'margin-right': v } }],
        [/^my-([^-]+)$/, ([, s]) => { const v = sizeValueExtractor(s); return { 'margin-top': v, 'margin-bottom': v } }],
        [/^p-([^-]+)$/, ([, s]) => ({ padding: sizeValueExtractor(s) })],
        [/^pt-([^-]+)$/, ([, s]) => ({ 'padding-top': sizeValueExtractor(s) })],
        [/^pr-([^-]+)$/, ([, s]) => ({ 'padding-right': sizeValueExtractor(s) })],
        [/^pb-([^-]+)$/, ([, s]) => ({ 'padding-bottom': sizeValueExtractor(s) })],
        [/^pl-([^-]+)$/, ([, s]) => ({ 'padding-left': sizeValueExtractor(s) })],
        [/^px-([^-]+)$/, ([, s]) => { const v = sizeValueExtractor(s); return { 'padding-left': v, 'padding-right': v } }],
        [/^py-([^-]+)$/, ([, s]) => { const v = sizeValueExtractor(s); return { 'padding-top': v, 'padding-bottom': v } }],
        [/^border-t-(?:w-)?(.+)$/, ([, s]) => ({ 'border-top-width': sizeValueExtractor(s) })],
        [/^border-r-(?:w-)?(.+)$/, ([, s]) => ({ 'border-right-width': sizeValueExtractor(s) })],
        [/^border-b-(?:w-)?(.+)$/, ([, s]) => ({ 'border-bottom-width': sizeValueExtractor(s) })],
        [/^border-l-(?:w-)?(.+)$/, ([, s]) => ({ 'border-left-width': sizeValueExtractor(s) })],
        [/^border-t-(solid|dashed|dotted|double|groove|ridge|inset|outset|none|hidden)$/, ([, s]) => ({ 'border-top-style': s })],
        [/^border-r-(solid|dashed|dotted|double|groove|ridge|inset|outset|none|hidden)$/, ([, s]) => ({ 'border-right-style': s })],
        [/^border-b-(solid|dashed|dotted|double|groove|ridge|inset|outset|none|hidden)$/, ([, s]) => ({ 'border-bottom-style': s })],
        [/^border-l-(solid|dashed|dotted|double|groove|ridge|inset|outset|none|hidden)$/, ([, s]) => ({ 'border-left-style': s })],
        [/^rounded-tl(?:-(.+))?$/, ([, s]) => ({ 'border-top-left-radius': s ? sizeValueExtractor(s) : '1px' })],
        [/^rounded-tr(?:-(.+))?$/, ([, s]) => ({ 'border-top-right-radius': s ? sizeValueExtractor(s) : '1px' })],
        [/^rounded-br(?:-(.+))?$/, ([, s]) => ({ 'border-bottom-right-radius': s ? sizeValueExtractor(s) : '1px' })],
        [/^rounded-bl(?:-(.+))?$/, ([, s]) => ({ 'border-bottom-left-radius': s ? sizeValueExtractor(s) : '1px' })],
        [/^rounded-t(?:-(.+))?$/, ([, s]) => { const v = s ? sizeValueExtractor(s) : '1px'; return { 'border-top-left-radius': v, 'border-top-right-radius': v } }],
        [/^rounded-r(?:-(.+))?$/, ([, s]) => { const v = s ? sizeValueExtractor(s) : '1px'; return { 'border-top-right-radius': v, 'border-bottom-right-radius': v } }],
        [/^rounded-b(?:-(.+))?$/, ([, s]) => { const v = s ? sizeValueExtractor(s) : '1px'; return { 'border-bottom-left-radius': v, 'border-bottom-right-radius': v } }],
        [/^rounded-l(?:-(.+))?$/, ([, s]) => { const v = s ? sizeValueExtractor(s) : '1px'; return { 'border-top-left-radius': v, 'border-bottom-left-radius': v } }],
        [/^border-t-c-(.+)$/, ([, c], { theme }) => ({ 'border-top-color': colorValueExtractor(c, theme) })],
        [/^border-r-c-(.+)$/, ([, c], { theme }) => ({ 'border-right-color': colorValueExtractor(c, theme) })],
        [/^border-b-c-(.+)$/, ([, c], { theme }) => ({ 'border-bottom-color': colorValueExtractor(c, theme) })],
        [/^border-l-c-(.+)$/, ([, c], { theme }) => ({ 'border-left-color': colorValueExtractor(c, theme) })],
        // border-image-source
        // border-image-repeat
        // border-image-slice
        // border-image-width
        [/^border-(?:w-)?(.+)$/, ([, s]) => ({ 'border-width': sizeValueExtractor(s) })],
        [/^border-(solid|dashed|dotted|double|groove|ridge|inset|outset|none|hidden)$/, ([, s]) => ({ 'border-style': s })],
        [/^border-c-(.+)$/, ([, c], { theme }) => ({ 'border-color': colorValueExtractor(c, theme) })],
        // border-top
        // border-right
        // border-bottom
        // border-left
        // border
        [/^rounded(?:-(.+))?$/, ([, s]) => ({ 'border-radius': s ? sizeValueExtractor(s) : '1px' })],
        // border-image
        // outline-width
        [/^outline-c-(.+)$/, ([, c], { theme }) => ({ 'outline-color': colorValueExtractor(c, theme) })],
        // outline-offset
        // outline
        [/^bg-(.+)$/, ([, c], { theme }) => ({ 'background-color': colorValueExtractor(c, theme) })],
        // background-clip
        // background-origin
        // background-size
        // background-position
        // background-repeat
        // background-image
        // box-shadow
        // background-blend-mode
        // background
        [/^transition(?:-([a-zA-Z-]+(?:,[a-zA-Z-]+)*))?$/, ([, prop]) => ({ 'transition-property': prop ? prop.split(',').map(p => p === 'colors' ? 'color, background-color, border-color' : p).join(',') : 'all', 'transition-timing-function': 'cubic-bezier(0.4, 0, 0.2, 1)', 'transition-duration': '150ms' })],
        [/^duration-(\d+)$/, ([, d]) => ({ 'transition-duration': `${d}ms` })],
        [/^ease-([a-zA-Z0-9-]+)$/, ([, ease]) => ({ 'transition-timing-function': ease })], // ease-linear, ease-in, etc.
        // animation-*
        // border-spacing

        [/^text-accent$/, () => ({ color: 'var(--gtk-accent-fg-color, var(--gtk-accent-color))' })],
        [/^bg-accent$/, () => ({ 'background-color': 'var(--gtk-accent-bg-color, var(--gtk-accent-color))' })],



        [/^(text|bg|border-c)-(transparent|currentColor)$/, ([_, propPrefix, val]) => {
            const propertyMap: Record<string, string> = {
                text: 'color',
                bg: 'background-color',
                'border-c': 'border-color',
            }
            return { [propertyMap[propPrefix]]: val }
        }],

    ],
    theme: {
        colors: {
        },
    },
    shortcuts: [],
    variants: [
        {
            name: 'backdrop',
            match: (matcher) => {
                if (matcher.startsWith('backdrop:')) {
                    return {
                        matcher: matcher.slice(9),
                        selector: (s) => `${s}:backdrop`,
                    }
                }
            },
        },
        {
            name: 'selected',
            match: (matcher) => {
                if (matcher.startsWith('selected:')) {
                    return {
                        matcher: matcher.slice(9),
                        selector: (s) => `${s}:selected`,
                    }
                }
            }
        },
        {
            name: 'checked',
            match: (matcher) => {
                if (matcher.startsWith('checked:')) {
                    return {
                        matcher: matcher.slice(8),
                        selector: (s) => `${s}:checked`,
                    }
                }
            }
        },
        // :disabled, :active, :focus, :hover はデフォルトでサポートされていることが多い
        // GTK特有の :insensitive (CSSでは :disabled に近しい)
        {
            name: 'insensitive',
            match: (matcher) => {
                if (matcher.startsWith('insensitive:')) {
                    return {
                        matcher: matcher.slice(12),
                        // GTKの insensitive は CSS の :disabled と挙動が似ているが、
                        // 場合によっては .insensitive クラスや属性セレクタ [gtk-insensitive="true"] などで
                        // スタイルされることもある。ここでは :disabled を使う。
                        selector: (s) => `${s}:disabled, ${s}[disabled]`,
                    }
                }
            }
        },
        // :link, :visited
        { name: 'link', match: (m) => m.startsWith('link:') ? { matcher: m.slice(5), selector: s => `${s}:link` } : undefined },
        { name: 'visited', match: (m) => m.startsWith('visited:') ? { matcher: m.slice(8), selector: s => `${s}:visited` } : undefined },
    ],
})
