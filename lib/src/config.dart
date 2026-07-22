import 'dart:ui' show Color;

import 'types.dart';

/// Fully-resolved rendering configuration shared by every painter.
class BeamConfig {
  const BeamConfig({
    required this.size,
    required this.colorVariant,
    required this.isDark,
    required this.borderRadius,
    required this.borderWidth,
    required this.duration,
    required this.strokeOpacity,
    required this.innerOpacity,
    required this.bloomOpacity,
    required this.innerShadow,
    required this.brightness,
    required this.saturation,
    required this.hueRange,
    required this.staticColors,
    required this.strength,
    required this.hairlineOpacity,
    this.strokeOpacityFactor = 1,
    this.innerOpacityFactor = 1,
    this.bloomOpacityFactor = 1,
    this.glowBoost = 1,
    this.coreBlur,
    this.bloomBlur,
    this.glowBrightness,
    this.glowSaturation,
    this.hueBase = 0,
  });

  final BorderBeamSize size;
  final BorderBeamColorVariant colorVariant;
  final bool isDark;
  final double borderRadius;
  final double borderWidth;
  final double duration;
  final double strokeOpacity;
  final double innerOpacity;
  final double bloomOpacity;
  final Color innerShadow;
  final double brightness;
  final double saturation;
  final double hueRange;
  final bool staticColors;
  final double strength;
  final double hairlineOpacity;

  // Consumer tuning hooks (parity with the CSS custom-property hooks).
  final double strokeOpacityFactor;
  final double innerOpacityFactor;
  final double bloomOpacityFactor;
  final double glowBoost;
  final double? coreBlur;
  final double? bloomBlur;
  final double? glowBrightness;
  final double? glowSaturation;
  final double hueBase;

  bool get isMono => colorVariant == BorderBeamColorVariant.mono;

  /// Mono variant gets 50% lower opacity (rotate/pulse variants only).
  double get monoMul => isMono ? 0.5 : 1.0;

  @override
  bool operator ==(Object other) {
    return other is BeamConfig &&
        other.size == size &&
        other.colorVariant == colorVariant &&
        other.isDark == isDark &&
        other.borderRadius == borderRadius &&
        other.borderWidth == borderWidth &&
        other.duration == duration &&
        other.strokeOpacity == strokeOpacity &&
        other.innerOpacity == innerOpacity &&
        other.bloomOpacity == bloomOpacity &&
        other.innerShadow == innerShadow &&
        other.brightness == brightness &&
        other.saturation == saturation &&
        other.hueRange == hueRange &&
        other.staticColors == staticColors &&
        other.strength == strength &&
        other.hairlineOpacity == hairlineOpacity &&
        other.strokeOpacityFactor == strokeOpacityFactor &&
        other.innerOpacityFactor == innerOpacityFactor &&
        other.bloomOpacityFactor == bloomOpacityFactor &&
        other.glowBoost == glowBoost &&
        other.coreBlur == coreBlur &&
        other.bloomBlur == bloomBlur &&
        other.glowBrightness == glowBrightness &&
        other.glowSaturation == glowSaturation &&
        other.hueBase == hueBase;
  }

  @override
  int get hashCode => Object.hashAll([
        size, colorVariant, isDark, borderRadius, borderWidth, duration,
        strokeOpacity, innerOpacity, bloomOpacity, innerShadow, brightness,
        saturation, hueRange, staticColors, strength, hairlineOpacity,
        strokeOpacityFactor, innerOpacityFactor, bloomOpacityFactor, glowBoost,
        coreBlur, bloomBlur, glowBrightness, glowSaturation, hueBase,
      ]);
}
