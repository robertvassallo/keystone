# Tailwind CSS

## Role

Tailwind is the **default** way to apply styles. Use SCSS modules only when Tailwind can't express the rule cleanly, or when the same composition is reused across components.

## When Tailwind, when SCSS

| Use Tailwind for | Use SCSS for |
|---|---|
| Layout (flex, grid, gap, padding, margin) | Design-token files |
| Spacing, sizing, typography | Complex pseudo-element styles, animations |
| Colours via theme tokens | Print styles |
| State variants (hover, focus, dark mode) | Reset / base styles |
| Responsive breakpoints | Component styles reused 3+ places that don't justify a React component |

## Theme — tokens, not magic values

The Tailwind config consumes design tokens; never hard-code colours / spacing in `tailwind.config.ts`.

```ts
// tailwind.config.ts
import preset from '@keystone/config/tailwind.preset';
export default { presets: [preset], content: [...] };
```

The preset (`packages/config/tailwind.preset.ts`) maps theme keys to CSS custom properties from `packages/tokens`:

```ts
theme: {
  colors: {
    bg: {
      canvas: 'var(--color-bg-canvas)',
      surface: 'var(--color-bg-surface)',
    },
    fg: {
      DEFAULT: 'var(--color-fg-default)',
      muted: 'var(--color-fg-muted)',
    },
    accent: {
      DEFAULT: 'var(--color-accent-fg)',
      emphasis: 'var(--color-accent-emphasis)',
    },
  },
  // ...
}
```

Result: `bg-bg-canvas`, `text-fg-muted`, `border-accent`. Never `text-gray-700`, `bg-indigo-600` directly — those are primitive layer tokens, not semantic.

## Class organisation

- Use `clsx` / `cn` helper for conditionals; never string concatenation.
- The Prettier Tailwind plugin sorts classes — don't fight it.
- Group classes by concern when manually authored (layout / spacing / colour / state):

```tsx
className={cn(
  'flex items-center justify-between',     // layout
  'gap-3 px-4 py-2',                       // spacing
  'rounded-md border border-border-subtle',// shape
  'bg-bg-surface text-fg',                 // colour
  'hover:bg-bg-canvas focus-visible:ring-2',// state
  isActive && 'bg-accent text-accent-fg',  // conditional
)}
```

## Extraction rules

A repeated Tailwind string is a code smell. Extract when the **same** class string is used **3 or more** times:

1. First, ask: should this be a React component? (Almost always yes — `<Button>`, `<Card>`.)
2. Otherwise, use **CVA** (`class-variance-authority`) to express variants:

```tsx
import { cva } from 'class-variance-authority';

const button = cva(
  'inline-flex items-center justify-center rounded-md font-medium focus-visible:ring-2',
  {
    variants: {
      intent: {
        primary: 'bg-accent text-accent-fg hover:bg-accent-emphasis',
        secondary: 'bg-bg-surface text-fg border border-border-subtle hover:bg-bg-canvas',
        danger: 'bg-danger text-danger-fg hover:bg-danger-emphasis',
      },
      size: {
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4 text-sm',
        lg: 'h-12 px-6 text-base',
      },
    },
    defaultVariants: { intent: 'secondary', size: 'md' },
  },
);
```

3. Last resort: `@apply` in a CSS module. Acceptable for global primitives (`prose`, `link`).

## Arbitrary values

`text-[14px]`, `bg-[#abc123]` are forbidden — they bypass the design system. If you need a value the theme doesn't have, **add it to the theme**, with a justification commit.

Exception: layout one-offs that genuinely don't belong in the system, like `top-[73px]` for compensating a fixed header. Comment why.

## State and variants

- Use `focus-visible:` not `focus:` for focus rings — focus-visible respects keyboard vs mouse.
- Dark mode: rely on `[data-theme="dark"]` selector configured in the preset; tokens flip automatically.

## Anti-patterns

| Don't | Do |
|---|---|
| `text-gray-700` | `text-fg-muted` (semantic token) |
| `bg-[#1f2937]` | Add to theme; use semantic class |
| 5 `<div>`s with the same 8-class string | Extract to a component |
| `className={`btn ${size === 'lg' ? 'btn-lg' : ''}`}` | Use `cva` |
| `!important` overrides via `!` prefix | Refactor specificity / variant |
| Tailwind classes in a SCSS file via `@apply` everywhere | Use components / CVA instead |

## Review checklist

- [ ] No raw colour / size values used (theme tokens only)
- [ ] Repeated class strings (≥ 3 uses) extracted to a component or CVA
- [ ] `focus-visible:` used for focus indicators
- [ ] `cn` / `clsx` used for conditionals (no string concat)
- [ ] Dark-mode tokens flow from custom properties, not duplicated classes
