# Changelog

## 1.0.1

- `customColors`: bring your own palette — colors are distributed cyclically
  over the gradient slots and rendered as supplied (hue-shift disabled).
- Oversized `borderRadius` values are clamped to the box, so `999` produces
  a stadium/pill shape (matching CSS behavior).
- Blur filters use `TileMode.decal` for CSS-accurate edge behavior.

## 1.0.0

Initial release — a Flutter port of
[border-beam](https://github.com/Jakubantalik/border-beam) by Jakub Antalik
(visual parity with its v1.3.0).

- All five types: `sm`, `md`, `line`, `pulse-inner`, `pulse-outside`
- Four color variants: `colorful`, `mono`, `ocean`, `sunset`
- Dark / light / auto themes, `strength`, `duration`, `active` with fade
  in/out callbacks, hue-shift controls, and the pulse consumer tuning hooks
  (`glowBoost`, `coreBlur`, `bloomBlur`, `glowBrightness`, `glowSaturation`,
  layer opacity factors)
- Performance: the pulse breathing is frame-capped to ~30fps, the heavy
  blurred bloom layers are frozen and cached as rasters (only a cheap
  hue-rotate color filter varies per frame), the wrapped child sits in its own
  `RepaintBoundary` and never repaints, and all tickers stop while the effect
  is inactive.

Known limitation: rendering is designed for Impeller/Skia native targets
(iOS, Android, macOS, Windows, Linux). Flutter Web's renderer mishandles the
`saveLayer` blend-mode masking the rotate/line types rely on, so web is not
supported.
