# border_beam_flutter

Animated border beam effect for Flutter. A lightweight widget that adds a
traveling or breathing glow animation around any element — cards, buttons,
inputs, or search bars.

A Flutter port of the
[border-beam](https://github.com/Jakubantalik/border-beam) React package by
[Jakub Antalik](https://github.com/Jakubantalik), with pixel-level parity of
its gradients, masks, and motion.

## Install

```yaml
dependencies:
  border_beam_flutter: ^1.0.1
```

## Quick start

```dart
import 'package:border_beam_flutter/border_beam_flutter.dart';

BorderBeam(
  child: Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: const Color(0xFF1D1D1D),
    ),
    child: const Text('Your content here'),
  ),
)
```

The widget wraps your content and overlays the animated beam effect. Pass
`borderRadius` matching your child's radius (there is no DOM to auto-detect it
from; it falls back to the size preset default). Oversized radii are clamped
to the box, so `borderRadius: 999` produces a stadium/pill shape.

## Types

Built-in presets control the glow style and motion. They fall into two
families:

### Rotate (traveling beam)

```dart
BorderBeam(size: BorderBeamSize.md,   child: card)        // Full border glow (default)
BorderBeam(size: BorderBeamSize.sm,   child: iconButton)  // Compact glow for small elements
BorderBeam(size: BorderBeamSize.line, child: searchBar)   // Bottom-only traveling glow
```

### Pulse (breathing glow, no rotation)

```dart
BorderBeam(size: BorderBeamSize.pulseInner,   child: card) // Contained breathing border glow
BorderBeam(size: BorderBeamSize.pulseOutside, child: card) // Outward-blooming halo
```

> **`pulseOutside` requires an opaque wrapped child.** The colorful core and
> halo render *behind* your content and bloom outward, so only the part that
> spills beyond the element shows. Make sure the surrounding layout has room
> for the halo to spill (the effect does not clip).
>
> **`pulseOutside` relies on the wrapped element's own 1px border as the idle
> hairline.** If your child has no border, add a subtle 1px border so the edge
> stays defined while the beam is faded out.

## Color variants

```dart
BorderBeam(colorVariant: BorderBeamColorVariant.colorful, child: c) // Rainbow (default)
BorderBeam(colorVariant: BorderBeamColorVariant.mono,     child: c) // Grayscale
BorderBeam(colorVariant: BorderBeamColorVariant.ocean,    child: c) // Blue-purple tones
BorderBeam(colorVariant: BorderBeamColorVariant.sunset,   child: c) // Orange-yellow-red tones
```

All variants except `mono` animate through a hue-shift cycle.

Or bring your own colors — they are distributed cyclically over the gradient
slots of the effect (any number of colors works) and rendered as supplied,
with the hue-shift disabled:

```dart
BorderBeam(
  customColors: const [Color(0xFF00E5A0), Color(0xFF7C4DFF)],
  child: c,
)
```

## Theme

```dart
BorderBeam(theme: BorderBeamTheme.dark,  child: c) // Dark background (default)
BorderBeam(theme: BorderBeamTheme.light, child: c) // Light background
BorderBeam(theme: BorderBeamTheme.auto,  child: c) // Follows platform brightness
```

## Strength

```dart
BorderBeam(strength: 0.7, child: c) // 70% intensity, child unaffected
```

## Play / pause

```dart
BorderBeam(
  active: active,
  onDeactivate: () => debugPrint('faded out'),
  child: c,
)
```

Toggling `active` fades the effect in (0.6s) and out (0.5s); the ticker stops
entirely once faded out.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | — | Content to wrap |
| `size` | `BorderBeamSize` | `md` | Size/type preset |
| `colorVariant` | `BorderBeamColorVariant` | `colorful` | Color palette |
| `customColors` | `List<Color>?` | — | Custom colors (overrides `colorVariant`) |
| `theme` | `BorderBeamTheme` | `dark` | Background adaptation |
| `strength` | `double` | `1` | Effect opacity (0–1), beam layers only |
| `duration` | `double?` | `1.96` / `3.1` / `2.3` | Cycle duration in seconds (rotate / line / pulse) |
| `active` | `bool` | `true` | Whether the animation is playing |
| `borderRadius` | `double?` | preset | Border radius in logical px |
| `brightness` | `double?` | per-type | Glow brightness multiplier |
| `saturation` | `double?` | per-theme | Glow saturation multiplier |
| `hueRange` | `double` | `30` | Hue rotation range in degrees |
| `staticColors` | `bool` | `false` | Disable the hue-shift animation |
| `onActivate` | `VoidCallback?` | — | Called when fade-in completes |
| `onDeactivate` | `VoidCallback?` | — | Called when fade-out completes |

Pulse tuning hooks (parity with the CSS custom-property hooks):
`strokeOpacityFactor`, `innerOpacityFactor`, `bloomOpacityFactor`,
`glowBoost`, `coreBlur`, `bloomBlur`, `glowBrightness`, `glowSaturation`,
`hueBase`.

## Performance

Designed to be cheap enough for always-on ambient use on mobile:

- The pulse breathing is driven at a capped ~30fps — the motion is slow, so
  halving the paint frequency is imperceptible.
- The heavy blurred bloom layers are **frozen** at the breathing time-average
  and painted once into a cached raster; only a cheap hue-rotate
  `ColorFilter` varies per frame.
- The wrapped child lives in its own `RepaintBoundary` and never repaints
  because of the effect; the effect layers likewise never invalidate the
  child.
- All tickers stop while `active` is false (after the fade-out completes),
  and respect `TickerMode`.
- The pulse types honor the platform's reduce-motion setting
  (`MediaQuery.disableAnimations`), matching the web version's
  `prefers-reduced-motion` behavior.

## Platform support

iOS, Android, macOS, Windows, Linux (Impeller/Skia). **Flutter Web is not
supported** — its renderer mishandles the `saveLayer` blend-mode masking the
rotate/line types rely on.

## Accessibility

The effect layers are purely decorative and wrapped in `IgnorePointer`, so
they never interfere with hit-testing or semantics.

## Credits

Ported from [border-beam](https://github.com/Jakubantalik/border-beam) by
[Jakub Antalik](https://github.com/Jakubantalik) — thanks for the original
design ([live demo](https://beam.jakubantalik.com)).

## License

[MIT](./LICENSE), original copyright retained.
