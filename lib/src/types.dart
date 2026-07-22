import 'dart:ui' show Color;

/// Size/type preset for the border beam effect.
///
/// Rotate family (traveling/spinning beam):
/// - [sm]: Small button-sized with compact glow
/// - [md]: Medium card-sized with full border glow
/// - [line]: Bottom-only traveling glow with breathe and spike animations
///
/// Pulse family (breathing glow, no rotation):
/// - [pulseOutside]: Glow blooms OUTWARD beyond the element (uncropped halo)
/// - [pulseInner]: Glow breathes contained within the element's border
enum BorderBeamSize { sm, md, line, pulseOutside, pulseInner }

/// Theme mode for adapting beam colors to the background.
///
/// `auto` follows the platform brightness (the Flutter equivalent of
/// `prefers-color-scheme`).
enum BorderBeamTheme { dark, light, auto }

/// Color variant for the beam effect.
/// - [colorful]: Full rainbow spectrum (default)
/// - [mono]: Monochromatic grayscale
/// - [ocean]: Blue and purple tones
/// - [sunset]: Warm orange, yellow, and red tones
enum BorderBeamColorVariant { colorful, mono, ocean, sunset }

/// Configuration for a size preset.
class SizeConfig {
  const SizeConfig({
    required this.borderRadius,
    required this.borderWidth,
    this.width,
    this.height,
  });

  final double borderRadius;
  final double borderWidth;
  final double? width;
  final double? height;
}

/// Theme color configuration for a size preset.
class ThemeColors {
  const ThemeColors({
    required this.strokeOpacity,
    required this.innerOpacity,
    required this.bloomOpacity,
    required this.innerShadow,
    required this.saturation,
    this.brightness,
    this.hairlineOpacity,
  });

  final double strokeOpacity;
  final double innerOpacity;
  final double bloomOpacity;

  /// Color of the inset highlight shadow (transparent for pulse types).
  final Color innerShadow;
  final double saturation;

  /// Optional per-type default brightness (used by pulse types).
  /// Falls back to 1.3.
  final double? brightness;

  /// Optional opacity of the 1px hairline border that frames the element
  /// (`pulseOutside` only). Falls back to 0 (no hairline).
  final double? hairlineOpacity;
}
