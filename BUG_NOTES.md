# Mobile/Narrow Flyout — Trailing Shadow Band

## Symptom
In mobile view (and narrow desktop), a dark grey band appears below the last
link in the flyout panel. It is most visible in dark mode.

## Root Cause
`mobile.scss` applies the flyout layout to `.top-level-links` via
`@include dropdown` (from `scss/mixins.scss`). That mixin includes:

```scss
box-shadow: 0 12px 12px rgb(0 0 0 / 15%);
```

This shadow is designed for the small, compact `.custom-header-dropdown`
(the sub-dropdown in desktop view). There it looks natural — a subtle
shadow below a floating box. However, the mobile flyout overrides
`position: fixed` and `width: 100%`, making the shadow span the **full
page width** below the panel edge. The result is a dark semi-transparent
bar that overlaps whatever page content sits below the flyout.

## Why it doesn't happen in desktop view
The desktop `.custom-header-dropdown` is `max-width: 280px`. The shadow
only extends 12px below a small box, which blends into the page naturally.
The full-width flyout amplifies the same shadow across the entire viewport.

## Fix
Override `box-shadow: none` on `.top-level-links` in the mobile/narrow
flyout context (both `mobile.scss` and `desktop.scss` at the narrow
breakpoint). The `border-bottom` can also be removed since a full-width
panel doesn't need the floating-box treatment.

## Secondary Issue (padding)
`common.scss` sets `padding-block: 0.5rem` on `.custom-header-link`
(the top-level `<li>` items). This is appropriate for horizontal desktop
layout (items sit side-by-side in the header bar). In the vertical flyout,
this padding stacks and adds excess height to each item — especially
noticeable at the bottom of the last item. Overriding `padding-block: 0`
in mobile context is the fix, but requires a selector with higher
specificity than the three-class chain in `common.scss`
(`.custom-header-links .top-level-links .custom-header-link`).
Use `li.custom-header-link` (element + class) to win the cascade.
