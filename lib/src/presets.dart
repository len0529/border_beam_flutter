// Data tables ported 1:1 from the React package's src/styles.ts.
// Positions are stored as fractions of the element box (CSS percentages / 100);
// sizes are the ellipse radii in logical pixels (CSS explicit gradient sizes).
import 'dart:ui' show Color;

import 'types.dart';

/// Size presets for border radius and dimensions.
const Map<BorderBeamSize, SizeConfig> sizePresets = {
  BorderBeamSize.sm:
      SizeConfig(borderRadius: 32, borderWidth: 1, width: 70, height: 36),
  BorderBeamSize.md: SizeConfig(borderRadius: 16, borderWidth: 1),
  BorderBeamSize.line: SizeConfig(borderRadius: 16, borderWidth: 1),
  BorderBeamSize.pulseOutside: SizeConfig(borderRadius: 16, borderWidth: 1),
  BorderBeamSize.pulseInner: SizeConfig(borderRadius: 16, borderWidth: 1),
};

/// Per-size theme presets matching the tuned v5 control panel defaults.
const Map<BorderBeamSize, Map<BorderBeamTheme, ThemeColors>> sizeThemePresets =
    {
  BorderBeamSize.sm: {
    BorderBeamTheme.dark: ThemeColors(
      strokeOpacity: 0.46,
      innerOpacity: 0.24,
      bloomOpacity: 0.38,
      innerShadow: Color.fromRGBO(255, 255, 255, 0.3),
      saturation: 1.2,
    ),
    BorderBeamTheme.light: ThemeColors(
      strokeOpacity: 0.12,
      innerOpacity: 0.3,
      bloomOpacity: 0.16,
      innerShadow: Color.fromRGBO(0, 0, 0, 0.14),
      saturation: 1.8,
    ),
  },
  BorderBeamSize.md: {
    BorderBeamTheme.dark: ThemeColors(
      strokeOpacity: 0.26,
      innerOpacity: 0.42,
      bloomOpacity: 0.24,
      innerShadow: Color.fromRGBO(255, 255, 255, 0.27),
      saturation: 1.2,
    ),
    BorderBeamTheme.light: ThemeColors(
      strokeOpacity: 0.12,
      innerOpacity: 0.26,
      bloomOpacity: 0.34,
      innerShadow: Color.fromRGBO(0, 0, 0, 0.14),
      saturation: 1.5,
    ),
  },
  BorderBeamSize.line: {
    BorderBeamTheme.dark: ThemeColors(
      strokeOpacity: 1.14,
      innerOpacity: 0.7,
      bloomOpacity: 0.8,
      innerShadow: Color.fromRGBO(255, 255, 255, 0.1),
      saturation: 1.2,
    ),
    BorderBeamTheme.light: ThemeColors(
      strokeOpacity: 0.16,
      innerOpacity: 0.32,
      bloomOpacity: 0.3,
      innerShadow: Color.fromRGBO(0, 0, 0, 0.14),
      saturation: 1.95,
    ),
  },
  // Pulse Outside — outward-blooming breathe (ported from v5 c6).
  BorderBeamSize.pulseOutside: {
    BorderBeamTheme.dark: ThemeColors(
      strokeOpacity: 0.94,
      innerOpacity: 0.34,
      bloomOpacity: 0.3,
      innerShadow: Color.fromRGBO(0, 0, 0, 0),
      saturation: 1.2,
      brightness: 1.9,
      hairlineOpacity: 0,
    ),
    BorderBeamTheme.light: ThemeColors(
      strokeOpacity: 1.96,
      innerOpacity: 1.04,
      bloomOpacity: 0.42,
      innerShadow: Color.fromRGBO(0, 0, 0, 0),
      saturation: 0.6,
      brightness: 1.7,
      hairlineOpacity: 0,
    ),
  },
  // Pulse Inner — contained breathe (ported from v5 c4).
  BorderBeamSize.pulseInner: {
    BorderBeamTheme.dark: ThemeColors(
      strokeOpacity: 1.54,
      innerOpacity: 0.44,
      bloomOpacity: 0.66,
      innerShadow: Color.fromRGBO(0, 0, 0, 0),
      saturation: 1.2,
      brightness: 0.75,
    ),
    BorderBeamTheme.light: ThemeColors(
      strokeOpacity: 0.32,
      innerOpacity: 0.4,
      bloomOpacity: 0.8,
      innerShadow: Color.fromRGBO(0, 0, 0, 0),
      saturation: 0.75,
      brightness: 1.3,
    ),
  },
};

/// One `radial-gradient(ellipse w h at x y, color, transparent)` blob.
/// [px]/[py] are fractions of the box; [w]/[h] are the ellipse radii in px.
class GradientBlob {
  const GradientBlob(this.color, this.px, this.py, this.w, this.h);
  final Color color;
  final double px;
  final double py;
  final double w;
  final double h;
}

/// Beam spike accent colors used by the line variant's bloom.
class SpikeColors {
  const SpikeColors(this.primary, this.secondary);
  final Color primary;
  final Color secondary;
}

class ColorPalette {
  const ColorPalette(
      {required this.border, required this.spike, required this.spikeLt});
  final List<GradientBlob> border;
  final SpikeColors spike;
  final SpikeColors spikeLt;
}

/// Color palettes for each color variant (medium/border sizes + pulse family).
const Map<BorderBeamColorVariant, ColorPalette> colorPalettes = {
  BorderBeamColorVariant.colorful: ColorPalette(
    border: [
      GradientBlob(Color.fromRGBO(255, 50, 100, 1), 0.33, -0.074, 70, 40),
      GradientBlob(Color.fromRGBO(40, 140, 255, 1), 0.12, -0.05, 60, 35),
      GradientBlob(Color.fromRGBO(50, 200, 80, 1), 0.021, 0.683, 40, 70),
      GradientBlob(Color.fromRGBO(30, 185, 170, 1), 0.021, 0.683, 20, 35),
      GradientBlob(Color.fromRGBO(100, 70, 255, 1), 0.744, 1.0, 180, 32),
      GradientBlob(Color.fromRGBO(40, 140, 255, 1), 0.55, 1.0, 85, 26),
      GradientBlob(Color.fromRGBO(255, 120, 40, 1), 0.939, 0.0, 74, 32),
      GradientBlob(Color.fromRGBO(240, 50, 180, 1), 1.0, 0.271, 26, 42),
      GradientBlob(Color.fromRGBO(180, 40, 240, 1), 1.0, 0.271, 52, 48),
    ],
    spike: SpikeColors(
        Color.fromRGBO(255, 60, 80, 1), Color.fromRGBO(40, 190, 180, 0.98)),
    spikeLt: SpikeColors(
        Color.fromRGBO(200, 30, 60, 1), Color.fromRGBO(20, 150, 140, 1)),
  ),
  BorderBeamColorVariant.mono: ColorPalette(
    border: [
      GradientBlob(Color.fromRGBO(180, 180, 180, 1), 0.33, -0.074, 70, 40),
      GradientBlob(Color.fromRGBO(140, 140, 140, 1), 0.12, -0.05, 60, 35),
      GradientBlob(Color.fromRGBO(160, 160, 160, 1), 0.021, 0.683, 40, 70),
      GradientBlob(Color.fromRGBO(130, 130, 130, 1), 0.021, 0.683, 20, 35),
      GradientBlob(Color.fromRGBO(170, 170, 170, 1), 0.744, 1.0, 180, 32),
      GradientBlob(Color.fromRGBO(150, 150, 150, 1), 0.55, 1.0, 85, 26),
      GradientBlob(Color.fromRGBO(190, 190, 190, 1), 0.939, 0.0, 74, 32),
      GradientBlob(Color.fromRGBO(145, 145, 145, 1), 1.0, 0.271, 26, 42),
      GradientBlob(Color.fromRGBO(165, 165, 165, 1), 1.0, 0.271, 52, 48),
    ],
    spike: SpikeColors(
        Color.fromRGBO(200, 200, 200, 1), Color.fromRGBO(170, 170, 170, 1)),
    spikeLt: SpikeColors(
        Color.fromRGBO(80, 80, 80, 1), Color.fromRGBO(120, 120, 120, 1)),
  ),
  BorderBeamColorVariant.ocean: ColorPalette(
    border: [
      GradientBlob(Color.fromRGBO(100, 80, 220, 1), 0.33, -0.074, 70, 40),
      GradientBlob(Color.fromRGBO(60, 120, 255, 1), 0.12, -0.05, 60, 35),
      GradientBlob(Color.fromRGBO(80, 100, 200, 1), 0.021, 0.683, 40, 70),
      GradientBlob(Color.fromRGBO(50, 140, 220, 1), 0.021, 0.683, 20, 35),
      GradientBlob(Color.fromRGBO(120, 80, 255, 1), 0.744, 1.0, 180, 32),
      GradientBlob(Color.fromRGBO(70, 130, 255, 1), 0.55, 1.0, 85, 26),
      GradientBlob(Color.fromRGBO(140, 100, 240, 1), 0.939, 0.0, 74, 32),
      GradientBlob(Color.fromRGBO(90, 110, 230, 1), 1.0, 0.271, 26, 42),
      GradientBlob(Color.fromRGBO(130, 70, 255, 1), 1.0, 0.271, 52, 48),
    ],
    spike: SpikeColors(
        Color.fromRGBO(100, 120, 255, 1), Color.fromRGBO(130, 100, 220, 0.98)),
    spikeLt: SpikeColors(
        Color.fromRGBO(60, 60, 180, 1), Color.fromRGBO(80, 100, 200, 1)),
  ),
  BorderBeamColorVariant.sunset: ColorPalette(
    border: [
      GradientBlob(Color.fromRGBO(255, 80, 50, 1), 0.33, -0.074, 70, 40),
      GradientBlob(Color.fromRGBO(255, 160, 40, 1), 0.12, -0.05, 60, 35),
      GradientBlob(Color.fromRGBO(255, 120, 60, 1), 0.021, 0.683, 40, 70),
      GradientBlob(Color.fromRGBO(255, 200, 50, 1), 0.021, 0.683, 20, 35),
      GradientBlob(Color.fromRGBO(255, 100, 80, 1), 0.744, 1.0, 180, 32),
      GradientBlob(Color.fromRGBO(255, 180, 60, 1), 0.55, 1.0, 85, 26),
      GradientBlob(Color.fromRGBO(255, 60, 60, 1), 0.939, 0.0, 74, 32),
      GradientBlob(Color.fromRGBO(255, 140, 50, 1), 1.0, 0.271, 26, 42),
      GradientBlob(Color.fromRGBO(255, 90, 70, 1), 1.0, 0.271, 52, 48),
    ],
    spike: SpikeColors(
        Color.fromRGBO(255, 140, 80, 1), Color.fromRGBO(255, 100, 60, 0.98)),
    spikeLt: SpikeColors(
        Color.fromRGBO(200, 80, 40, 1), Color.fromRGBO(220, 120, 30, 1)),
  ),
};

class SmallPalette {
  const SmallPalette({required this.border, required this.inner});
  final List<GradientBlob> border;
  final List<GradientBlob> inner;
}

/// Small size color palettes (compact gradients for button-sized elements).
const Map<BorderBeamColorVariant, SmallPalette> smallColorPalettes = {
  BorderBeamColorVariant.colorful: SmallPalette(
    border: [
      GradientBlob(Color.fromRGBO(50, 200, 80, 1), 0.02, 0.68, 9, 18),
      GradientBlob(Color.fromRGBO(30, 185, 170, 1), 0.02, 0.68, 4, 8),
      GradientBlob(Color.fromRGBO(255, 120, 40, 1), 0.72, -0.03, 59, 9),
      GradientBlob(Color.fromRGBO(100, 70, 255, 1), 0.74, 1.0, 42, 7),
      GradientBlob(Color.fromRGBO(240, 50, 180, 1), 1.0, 0.27, 10, 17),
      GradientBlob(Color.fromRGBO(180, 40, 240, 1), 1.0, 0.27, 10, 18),
      GradientBlob(Color.fromRGBO(40, 140, 255, 1), 1.0, 0.27, 5, 10),
      GradientBlob(Color.fromRGBO(255, 50, 100, 1), 1.0, 0.27, 11, 12),
    ],
    inner: [
      GradientBlob(Color.fromRGBO(50, 200, 80, 0.5), 0.02, 0.68, 9, 18),
      GradientBlob(Color.fromRGBO(30, 185, 170, 0.45), 0.02, 0.68, 4, 8),
      GradientBlob(Color.fromRGBO(255, 120, 40, 0.35), 0.72, -0.03, 59, 9),
      GradientBlob(Color.fromRGBO(100, 70, 255, 0.35), 0.74, 1.0, 42, 7),
      GradientBlob(Color.fromRGBO(240, 50, 180, 0.3), 1.0, 0.27, 10, 17),
      GradientBlob(Color.fromRGBO(180, 40, 240, 0.4), 1.0, 0.27, 10, 18),
      GradientBlob(Color.fromRGBO(40, 140, 255, 0.3), 1.0, 0.27, 5, 10),
      GradientBlob(Color.fromRGBO(255, 50, 100, 0.3), 1.0, 0.27, 11, 12),
    ],
  ),
  BorderBeamColorVariant.mono: SmallPalette(
    border: [
      GradientBlob(Color.fromRGBO(160, 160, 160, 1), 0.02, 0.68, 9, 18),
      GradientBlob(Color.fromRGBO(140, 140, 140, 1), 0.02, 0.68, 4, 8),
      GradientBlob(Color.fromRGBO(180, 180, 180, 1), 0.72, -0.03, 59, 9),
      GradientBlob(Color.fromRGBO(150, 150, 150, 1), 0.74, 1.0, 42, 7),
      GradientBlob(Color.fromRGBO(170, 170, 170, 1), 1.0, 0.27, 10, 17),
      GradientBlob(Color.fromRGBO(155, 155, 155, 1), 1.0, 0.27, 10, 18),
      GradientBlob(Color.fromRGBO(145, 145, 145, 1), 1.0, 0.27, 5, 10),
      GradientBlob(Color.fromRGBO(165, 165, 165, 1), 1.0, 0.27, 11, 12),
    ],
    inner: [
      GradientBlob(Color.fromRGBO(160, 160, 160, 0.25), 0.02, 0.68, 9, 18),
      GradientBlob(Color.fromRGBO(140, 140, 140, 0.22), 0.02, 0.68, 4, 8),
      GradientBlob(Color.fromRGBO(180, 180, 180, 0.17), 0.72, -0.03, 59, 9),
      GradientBlob(Color.fromRGBO(150, 150, 150, 0.17), 0.74, 1.0, 42, 7),
      GradientBlob(Color.fromRGBO(170, 170, 170, 0.15), 1.0, 0.27, 10, 17),
      GradientBlob(Color.fromRGBO(155, 155, 155, 0.20), 1.0, 0.27, 10, 18),
      GradientBlob(Color.fromRGBO(145, 145, 145, 0.15), 1.0, 0.27, 5, 10),
      GradientBlob(Color.fromRGBO(165, 165, 165, 0.15), 1.0, 0.27, 11, 12),
    ],
  ),
  BorderBeamColorVariant.ocean: SmallPalette(
    border: [
      GradientBlob(Color.fromRGBO(60, 140, 200, 1), 0.02, 0.68, 9, 18),
      GradientBlob(Color.fromRGBO(50, 120, 180, 1), 0.02, 0.68, 4, 8),
      GradientBlob(Color.fromRGBO(100, 80, 220, 1), 0.72, -0.03, 59, 9),
      GradientBlob(Color.fromRGBO(80, 100, 255, 1), 0.74, 1.0, 42, 7),
      GradientBlob(Color.fromRGBO(120, 70, 240, 1), 1.0, 0.27, 10, 17),
      GradientBlob(Color.fromRGBO(90, 80, 220, 1), 1.0, 0.27, 10, 18),
      GradientBlob(Color.fromRGBO(70, 110, 255, 1), 1.0, 0.27, 5, 10),
      GradientBlob(Color.fromRGBO(110, 90, 230, 1), 1.0, 0.27, 11, 12),
    ],
    inner: [
      GradientBlob(Color.fromRGBO(60, 140, 200, 0.5), 0.02, 0.68, 9, 18),
      GradientBlob(Color.fromRGBO(50, 120, 180, 0.45), 0.02, 0.68, 4, 8),
      GradientBlob(Color.fromRGBO(100, 80, 220, 0.35), 0.72, -0.03, 59, 9),
      GradientBlob(Color.fromRGBO(80, 100, 255, 0.35), 0.74, 1.0, 42, 7),
      GradientBlob(Color.fromRGBO(120, 70, 240, 0.3), 1.0, 0.27, 10, 17),
      GradientBlob(Color.fromRGBO(90, 80, 220, 0.4), 1.0, 0.27, 10, 18),
      GradientBlob(Color.fromRGBO(70, 110, 255, 0.3), 1.0, 0.27, 5, 10),
      GradientBlob(Color.fromRGBO(110, 90, 230, 0.3), 1.0, 0.27, 11, 12),
    ],
  ),
  BorderBeamColorVariant.sunset: SmallPalette(
    border: [
      GradientBlob(Color.fromRGBO(255, 180, 50, 1), 0.02, 0.68, 9, 18),
      GradientBlob(Color.fromRGBO(255, 150, 40, 1), 0.02, 0.68, 4, 8),
      GradientBlob(Color.fromRGBO(255, 80, 60, 1), 0.72, -0.03, 59, 9),
      GradientBlob(Color.fromRGBO(255, 100, 80, 1), 0.74, 1.0, 42, 7),
      GradientBlob(Color.fromRGBO(255, 60, 80, 1), 1.0, 0.27, 10, 17),
      GradientBlob(Color.fromRGBO(255, 120, 60, 1), 1.0, 0.27, 10, 18),
      GradientBlob(Color.fromRGBO(255, 200, 50, 1), 1.0, 0.27, 5, 10),
      GradientBlob(Color.fromRGBO(255, 90, 70, 1), 1.0, 0.27, 11, 12),
    ],
    inner: [
      GradientBlob(Color.fromRGBO(255, 180, 50, 0.5), 0.02, 0.68, 9, 18),
      GradientBlob(Color.fromRGBO(255, 150, 40, 0.45), 0.02, 0.68, 4, 8),
      GradientBlob(Color.fromRGBO(255, 80, 60, 0.35), 0.72, -0.03, 59, 9),
      GradientBlob(Color.fromRGBO(255, 100, 80, 0.35), 0.74, 1.0, 42, 7),
      GradientBlob(Color.fromRGBO(255, 60, 80, 0.3), 1.0, 0.27, 10, 17),
      GradientBlob(Color.fromRGBO(255, 120, 60, 0.4), 1.0, 0.27, 10, 18),
      GradientBlob(Color.fromRGBO(255, 200, 50, 0.3), 1.0, 0.27, 5, 10),
      GradientBlob(Color.fromRGBO(255, 90, 70, 0.3), 1.0, 0.27, 11, 12),
    ],
  ),
};

/// One gradient blob of the line variant, offset in px from the traveling
/// beam's x position along the bottom edge.
class LineBlob {
  const LineBlob(this.color, this.sizeW, this.sizeH, this.offsetX, this.offsetY);
  final Color color;
  final double sizeW;
  final double sizeH;
  final double offsetX;
  final double offsetY;
}

class LinePalette {
  const LinePalette({required this.dark, required this.light});
  final List<LineBlob> dark;
  final List<LineBlob> light;
}

const Map<BorderBeamColorVariant, LinePalette> lineColorPalettes = {
  BorderBeamColorVariant.colorful: LinePalette(
    dark: [
      LineBlob(Color.fromRGBO(255, 50, 100, 1), 36, 36, 0, 2),
      LineBlob(Color.fromRGBO(40, 180, 220, 1), 30, 32, 39, 0),
      LineBlob(Color.fromRGBO(50, 200, 80, 1), 33, 28, -36, 2),
      LineBlob(Color.fromRGBO(180, 40, 240, 1), 29, 34, -54, 0),
      LineBlob(Color.fromRGBO(255, 160, 30, 1), 27, 30, 51, -1),
      LineBlob(Color.fromRGBO(100, 70, 255, 1), 36, 24, 21, 1),
      LineBlob(Color.fromRGBO(40, 140, 255, 1), 30, 22, -21, 0),
      LineBlob(Color.fromRGBO(240, 50, 180, 1), 25, 28, 66, 1),
      LineBlob(Color.fromRGBO(30, 185, 170, 1), 23, 30, -66, -1),
    ],
    light: [
      LineBlob(Color.fromRGBO(255, 50, 100, 1), 45, 36, 0, 2),
      LineBlob(Color.fromRGBO(40, 140, 255, 1), 35, 32, 65, 0),
      LineBlob(Color.fromRGBO(50, 200, 80, 1), 40, 28, -60, 2),
      LineBlob(Color.fromRGBO(180, 40, 240, 1), 35, 34, -90, 0),
      LineBlob(Color.fromRGBO(30, 185, 170, 1), 38, 30, 85, -1),
      LineBlob(Color.fromRGBO(100, 70, 255, 1), 50, 24, 35, 1),
      LineBlob(Color.fromRGBO(40, 140, 255, 1), 40, 22, -35, 0),
      LineBlob(Color.fromRGBO(255, 120, 40, 1), 35, 28, 110, 1),
      LineBlob(Color.fromRGBO(240, 50, 180, 1), 30, 30, -110, -1),
    ],
  ),
  BorderBeamColorVariant.mono: LinePalette(
    dark: [
      LineBlob(Color.fromRGBO(200, 200, 200, 1), 36, 36, 0, 2),
      LineBlob(Color.fromRGBO(170, 170, 170, 1), 30, 32, 39, 0),
      LineBlob(Color.fromRGBO(155, 155, 155, 1), 33, 28, -36, 2),
      LineBlob(Color.fromRGBO(185, 185, 185, 1), 29, 34, -54, 0),
      LineBlob(Color.fromRGBO(165, 165, 165, 1), 27, 30, 51, -1),
      LineBlob(Color.fromRGBO(180, 180, 180, 1), 36, 24, 21, 1),
      LineBlob(Color.fromRGBO(160, 160, 160, 1), 30, 22, -21, 0),
      LineBlob(Color.fromRGBO(175, 175, 175, 1), 25, 28, 66, 1),
      LineBlob(Color.fromRGBO(190, 190, 190, 1), 23, 30, -66, -1),
    ],
    light: [
      LineBlob(Color.fromRGBO(100, 100, 100, 1), 45, 36, 0, 2),
      LineBlob(Color.fromRGBO(80, 80, 80, 1), 35, 32, 65, 0),
      LineBlob(Color.fromRGBO(90, 90, 90, 1), 40, 28, -60, 2),
      LineBlob(Color.fromRGBO(70, 70, 70, 1), 35, 34, -90, 0),
      LineBlob(Color.fromRGBO(85, 85, 85, 1), 38, 30, 85, -1),
      LineBlob(Color.fromRGBO(95, 95, 95, 1), 50, 24, 35, 1),
      LineBlob(Color.fromRGBO(75, 75, 75, 1), 40, 22, -35, 0),
      LineBlob(Color.fromRGBO(105, 105, 105, 1), 35, 28, 110, 1),
      LineBlob(Color.fromRGBO(65, 65, 65, 1), 30, 30, -110, -1),
    ],
  ),
  BorderBeamColorVariant.ocean: LinePalette(
    dark: [
      LineBlob(Color.fromRGBO(100, 80, 220, 1), 36, 36, 0, 2),
      LineBlob(Color.fromRGBO(60, 120, 255, 1), 30, 32, 39, 0),
      LineBlob(Color.fromRGBO(80, 100, 200, 1), 33, 28, -36, 2),
      LineBlob(Color.fromRGBO(130, 70, 255, 1), 29, 34, -54, 0),
      LineBlob(Color.fromRGBO(70, 130, 255, 1), 27, 30, 51, -1),
      LineBlob(Color.fromRGBO(120, 80, 255, 1), 36, 24, 21, 1),
      LineBlob(Color.fromRGBO(90, 110, 230, 1), 30, 22, -21, 0),
      LineBlob(Color.fromRGBO(110, 90, 240, 1), 25, 28, 66, 1),
      LineBlob(Color.fromRGBO(140, 100, 255, 1), 23, 30, -66, -1),
    ],
    light: [
      LineBlob(Color.fromRGBO(80, 60, 200, 1), 45, 36, 0, 2),
      LineBlob(Color.fromRGBO(50, 100, 220, 1), 35, 32, 65, 0),
      LineBlob(Color.fromRGBO(70, 90, 190, 1), 40, 28, -60, 2),
      LineBlob(Color.fromRGBO(110, 60, 220, 1), 35, 34, -90, 0),
      LineBlob(Color.fromRGBO(60, 110, 230, 1), 38, 30, 85, -1),
      LineBlob(Color.fromRGBO(100, 70, 240, 1), 50, 24, 35, 1),
      LineBlob(Color.fromRGBO(80, 100, 210, 1), 40, 22, -35, 0),
      LineBlob(Color.fromRGBO(90, 80, 225, 1), 35, 28, 110, 1),
      LineBlob(Color.fromRGBO(120, 90, 245, 1), 30, 30, -110, -1),
    ],
  ),
  BorderBeamColorVariant.sunset: LinePalette(
    dark: [
      LineBlob(Color.fromRGBO(255, 100, 60, 1), 36, 36, 0, 2),
      LineBlob(Color.fromRGBO(255, 180, 50, 1), 30, 32, 39, 0),
      LineBlob(Color.fromRGBO(255, 140, 70, 1), 33, 28, -36, 2),
      LineBlob(Color.fromRGBO(255, 80, 80, 1), 29, 34, -54, 0),
      LineBlob(Color.fromRGBO(255, 200, 60, 1), 27, 30, 51, -1),
      LineBlob(Color.fromRGBO(255, 120, 50, 1), 36, 24, 21, 1),
      LineBlob(Color.fromRGBO(255, 160, 80, 1), 30, 22, -21, 0),
      LineBlob(Color.fromRGBO(255, 90, 60, 1), 25, 28, 66, 1),
      LineBlob(Color.fromRGBO(255, 70, 70, 1), 23, 30, -66, -1),
    ],
    light: [
      LineBlob(Color.fromRGBO(220, 80, 40, 1), 45, 36, 0, 2),
      LineBlob(Color.fromRGBO(230, 150, 30, 1), 35, 32, 65, 0),
      LineBlob(Color.fromRGBO(210, 110, 50, 1), 40, 28, -60, 2),
      LineBlob(Color.fromRGBO(200, 60, 60, 1), 35, 34, -90, 0),
      LineBlob(Color.fromRGBO(220, 170, 40, 1), 38, 30, 85, -1),
      LineBlob(Color.fromRGBO(210, 100, 30, 1), 50, 24, 35, 1),
      LineBlob(Color.fromRGBO(230, 130, 60, 1), 40, 22, -35, 0),
      LineBlob(Color.fromRGBO(190, 70, 50, 1), 35, 28, 110, 1),
      LineBlob(Color.fromRGBO(180, 50, 50, 1), 30, 30, -110, -1),
    ],
  ),
};

/// Inner gradient data for the line variant (matches v5.css exactly).
const Map<BorderBeamColorVariant, List<LineBlob>> lineInnerGradientData = {
  BorderBeamColorVariant.colorful: [
    LineBlob(Color.fromRGBO(255, 50, 100, 0.48), 33, 30, 0, 0),
    LineBlob(Color.fromRGBO(40, 180, 220, 0.42), 24, 26, 39, -3),
    LineBlob(Color.fromRGBO(50, 200, 80, 0.48), 27, 24, -36, 0),
    LineBlob(Color.fromRGBO(180, 40, 240, 0.42), 23, 28, -54, -2),
    LineBlob(Color.fromRGBO(255, 160, 30, 0.50), 24, 24, 51, -1),
    LineBlob(Color.fromRGBO(100, 70, 255, 0.45), 30, 20, 21, 0),
    LineBlob(Color.fromRGBO(40, 140, 255, 0.40), 25, 18, -21, -2),
    LineBlob(Color.fromRGBO(240, 50, 180, 0.45), 21, 24, 66, 0),
    LineBlob(Color.fromRGBO(30, 185, 170, 0.52), 18, 26, -66, -1),
  ],
  BorderBeamColorVariant.mono: [
    LineBlob(Color.fromRGBO(200, 200, 200, 0.48), 33, 30, 0, 0),
    LineBlob(Color.fromRGBO(170, 170, 170, 0.42), 24, 26, 39, -3),
    LineBlob(Color.fromRGBO(155, 155, 155, 0.48), 27, 24, -36, 0),
    LineBlob(Color.fromRGBO(185, 185, 185, 0.42), 23, 28, -54, -2),
    LineBlob(Color.fromRGBO(165, 165, 165, 0.50), 24, 24, 51, -1),
    LineBlob(Color.fromRGBO(180, 180, 180, 0.45), 30, 20, 21, 0),
    LineBlob(Color.fromRGBO(160, 160, 160, 0.40), 25, 18, -21, -2),
    LineBlob(Color.fromRGBO(175, 175, 175, 0.45), 21, 24, 66, 0),
    LineBlob(Color.fromRGBO(190, 190, 190, 0.52), 18, 26, -66, -1),
  ],
  BorderBeamColorVariant.ocean: [
    LineBlob(Color.fromRGBO(100, 80, 220, 0.48), 33, 30, 0, 0),
    LineBlob(Color.fromRGBO(60, 120, 255, 0.42), 24, 26, 39, -3),
    LineBlob(Color.fromRGBO(80, 100, 200, 0.48), 27, 24, -36, 0),
    LineBlob(Color.fromRGBO(130, 70, 255, 0.42), 23, 28, -54, -2),
    LineBlob(Color.fromRGBO(70, 130, 255, 0.50), 24, 24, 51, -1),
    LineBlob(Color.fromRGBO(120, 80, 255, 0.45), 30, 20, 21, 0),
    LineBlob(Color.fromRGBO(90, 110, 230, 0.40), 25, 18, -21, -2),
    LineBlob(Color.fromRGBO(110, 90, 240, 0.45), 21, 24, 66, 0),
    LineBlob(Color.fromRGBO(140, 100, 255, 0.52), 18, 26, -66, -1),
  ],
  BorderBeamColorVariant.sunset: [
    LineBlob(Color.fromRGBO(255, 100, 60, 0.48), 33, 30, 0, 0),
    LineBlob(Color.fromRGBO(255, 180, 50, 0.42), 24, 26, 39, -3),
    LineBlob(Color.fromRGBO(255, 140, 70, 0.48), 27, 24, -36, 0),
    LineBlob(Color.fromRGBO(255, 80, 80, 0.42), 23, 28, -54, -2),
    LineBlob(Color.fromRGBO(255, 200, 60, 0.50), 24, 24, 51, -1),
    LineBlob(Color.fromRGBO(255, 120, 50, 0.45), 30, 20, 21, 0),
    LineBlob(Color.fromRGBO(255, 160, 80, 0.40), 25, 18, -21, -2),
    LineBlob(Color.fromRGBO(255, 90, 60, 0.45), 21, 24, 66, 0),
    LineBlob(Color.fromRGBO(255, 70, 70, 0.52), 18, 26, -66, -1),
  ],
};

class BloomSpike {
  const BloomSpike(this.color1, this.color2);
  final Color color1;
  final Color color2;
}

class LineBloomTheme {
  const LineBloomTheme(this.spikes);
  final List<BloomSpike> spikes;
}

class LineBloomPalette {
  const LineBloomPalette({required this.dark, required this.light});
  final LineBloomTheme dark;
  final LineBloomTheme light;
}

const Map<BorderBeamColorVariant, LineBloomPalette> lineBloomColors = {
  BorderBeamColorVariant.colorful: LineBloomPalette(
    dark: LineBloomTheme([
      BloomSpike(
          Color.fromRGBO(100, 70, 255, 1), Color.fromRGBO(100, 70, 255, 1)),
      BloomSpike(Color.fromRGBO(255, 170, 40, 0.59),
          Color.fromRGBO(255, 170, 40, 0.29)),
      BloomSpike(
          Color.fromRGBO(50, 200, 100, 1), Color.fromRGBO(50, 200, 100, 1)),
      BloomSpike(Color.fromRGBO(200, 50, 240, 0.91),
          Color.fromRGBO(200, 50, 240, 0.45)),
      BloomSpike(
          Color.fromRGBO(40, 140, 255, 1), Color.fromRGBO(40, 140, 255, 1)),
    ]),
    light: LineBloomTheme([
      BloomSpike(
          Color.fromRGBO(80, 50, 200, 1), Color.fromRGBO(80, 50, 200, 0.8)),
      BloomSpike(Color.fromRGBO(210, 130, 0, 0.7),
          Color.fromRGBO(210, 130, 0, 0.46)),
      BloomSpike(
          Color.fromRGBO(30, 160, 70, 1), Color.fromRGBO(30, 160, 70, 0.82)),
      BloomSpike(
          Color.fromRGBO(160, 30, 190, 1), Color.fromRGBO(160, 30, 190, 0.7)),
      BloomSpike(
          Color.fromRGBO(30, 100, 200, 1), Color.fromRGBO(30, 100, 200, 0.78)),
    ]),
  ),
  BorderBeamColorVariant.mono: LineBloomPalette(
    dark: LineBloomTheme([
      BloomSpike(
          Color.fromRGBO(200, 200, 200, 1), Color.fromRGBO(200, 200, 200, 1)),
      BloomSpike(Color.fromRGBO(180, 180, 180, 0.59),
          Color.fromRGBO(180, 180, 180, 0.29)),
      BloomSpike(
          Color.fromRGBO(190, 190, 190, 1), Color.fromRGBO(190, 190, 190, 1)),
      BloomSpike(Color.fromRGBO(170, 170, 170, 0.91),
          Color.fromRGBO(170, 170, 170, 0.45)),
      BloomSpike(
          Color.fromRGBO(185, 185, 185, 1), Color.fromRGBO(185, 185, 185, 1)),
    ]),
    light: LineBloomTheme([
      BloomSpike(
          Color.fromRGBO(80, 80, 80, 1), Color.fromRGBO(80, 80, 80, 0.8)),
      BloomSpike(Color.fromRGBO(100, 100, 100, 0.7),
          Color.fromRGBO(100, 100, 100, 0.46)),
      BloomSpike(
          Color.fromRGBO(70, 70, 70, 1), Color.fromRGBO(70, 70, 70, 0.82)),
      BloomSpike(
          Color.fromRGBO(90, 90, 90, 1), Color.fromRGBO(90, 90, 90, 0.7)),
      BloomSpike(
          Color.fromRGBO(85, 85, 85, 1), Color.fromRGBO(85, 85, 85, 0.78)),
    ]),
  ),
  BorderBeamColorVariant.ocean: LineBloomPalette(
    dark: LineBloomTheme([
      BloomSpike(
          Color.fromRGBO(100, 80, 255, 1), Color.fromRGBO(100, 80, 255, 1)),
      BloomSpike(Color.fromRGBO(80, 130, 220, 0.59),
          Color.fromRGBO(80, 130, 220, 0.29)),
      BloomSpike(
          Color.fromRGBO(60, 100, 255, 1), Color.fromRGBO(60, 100, 255, 1)),
      BloomSpike(Color.fromRGBO(90, 120, 200, 0.91),
          Color.fromRGBO(90, 120, 200, 0.45)),
      BloomSpike(
          Color.fromRGBO(120, 90, 255, 1), Color.fromRGBO(120, 90, 255, 1)),
    ]),
    light: LineBloomTheme([
      BloomSpike(
          Color.fromRGBO(50, 40, 180, 1), Color.fromRGBO(50, 40, 180, 0.8)),
      BloomSpike(Color.fromRGBO(40, 80, 200, 0.7),
          Color.fromRGBO(40, 80, 200, 0.46)),
      BloomSpike(
          Color.fromRGBO(30, 50, 190, 1), Color.fromRGBO(30, 50, 190, 0.82)),
      BloomSpike(
          Color.fromRGBO(60, 90, 180, 1), Color.fromRGBO(60, 90, 180, 0.7)),
      BloomSpike(
          Color.fromRGBO(70, 60, 200, 1), Color.fromRGBO(70, 60, 200, 0.78)),
    ]),
  ),
  BorderBeamColorVariant.sunset: LineBloomPalette(
    dark: LineBloomTheme([
      BloomSpike(
          Color.fromRGBO(255, 100, 80, 1), Color.fromRGBO(255, 100, 80, 1)),
      BloomSpike(Color.fromRGBO(255, 150, 80, 0.59),
          Color.fromRGBO(255, 150, 80, 0.29)),
      BloomSpike(
          Color.fromRGBO(255, 80, 60, 1), Color.fromRGBO(255, 80, 60, 1)),
      BloomSpike(Color.fromRGBO(255, 120, 50, 0.91),
          Color.fromRGBO(255, 120, 50, 0.45)),
      BloomSpike(
          Color.fromRGBO(255, 140, 70, 1), Color.fromRGBO(255, 140, 70, 1)),
    ]),
    light: LineBloomTheme([
      BloomSpike(
          Color.fromRGBO(200, 60, 30, 1), Color.fromRGBO(200, 60, 30, 0.8)),
      BloomSpike(Color.fromRGBO(220, 100, 20, 0.7),
          Color.fromRGBO(220, 100, 20, 0.46)),
      BloomSpike(
          Color.fromRGBO(180, 40, 20, 1), Color.fromRGBO(180, 40, 20, 0.82)),
      BloomSpike(
          Color.fromRGBO(210, 80, 10, 1), Color.fromRGBO(210, 80, 10, 0.7)),
      BloomSpike(
          Color.fromRGBO(190, 70, 30, 1), Color.fromRGBO(190, 70, 30, 0.78)),
    ]),
  ),
};

// ── Pulse family tables (ported from v5 Card 4 / Card 5) ────────────────────

enum PulseQuad { tl, tr, bl, br }

class PulseRingEntry {
  const PulseRingEntry(this.region, this.quad);
  final int region; // 1..3
  final PulseQuad quad;
}

/// Which size-region (g1/g2/g3) and opacity-quadrant each of the 9 palette
/// gradients belongs to (taken from the v5 Card 4 `::after` ordering).
const List<PulseRingEntry> pulseRingMap = [
  PulseRingEntry(1, PulseQuad.tl),
  PulseRingEntry(2, PulseQuad.tl),
  PulseRingEntry(3, PulseQuad.bl),
  PulseRingEntry(1, PulseQuad.bl),
  PulseRingEntry(2, PulseQuad.br),
  PulseRingEntry(3, PulseQuad.br),
  PulseRingEntry(1, PulseQuad.tr),
  PulseRingEntry(2, PulseQuad.tr),
  PulseRingEntry(3, PulseQuad.tr),
];

/// Card 4 inner-perimeter gradient sizes — slightly smaller than the ring.
const List<List<double>> pulseInnerSizes = [
  [65, 35], [55, 30], [35, 65], [15, 30], [173, 28], [80, 22], [69, 28],
  [22, 38], [47, 44],
];

class PulseGradientDef {
  const PulseGradientDef(this.ci, this.region, this.quad, this.w, this.h,
      [this.x, this.y]);
  final int ci; // index into colorPalettes[variant].border
  final int region;
  final PulseQuad quad;
  final double w;
  final double h;

  /// Explicit position fraction (outer effect); falls back to the palette pos.
  final double? x;
  final double? y;
}

/// Card 4 bloom — 7 of the 9 colors, expanded sizes (positions from palette).
const List<PulseGradientDef> pulseInnerBloom = [
  PulseGradientDef(0, 1, PulseQuad.tl, 84, 48),
  PulseGradientDef(1, 2, PulseQuad.tl, 72, 42),
  PulseGradientDef(2, 3, PulseQuad.bl, 48, 84),
  PulseGradientDef(4, 2, PulseQuad.br, 216, 38),
  PulseGradientDef(5, 3, PulseQuad.br, 102, 31),
  PulseGradientDef(6, 1, PulseQuad.tr, 89, 38),
  PulseGradientDef(8, 3, PulseQuad.tr, 62, 58),
];

/// Card 5 outward core (hairline stroke + glow share this edge-positioned set).
const List<PulseGradientDef> pulseOuterCore = [
  PulseGradientDef(0, 1, PulseQuad.tl, 80, 19, 0.27, 0.0),
  PulseGradientDef(6, 2, PulseQuad.tr, 74, 11, 0.73, -0.01),
  PulseGradientDef(7, 3, PulseQuad.tr, 15, 44, 1.0, 0.33),
  PulseGradientDef(8, 1, PulseQuad.br, 19, 38, 1.01, 0.72),
  PulseGradientDef(4, 2, PulseQuad.br, 84, 13, 0.67, 1.0),
  PulseGradientDef(1, 3, PulseQuad.bl, 60, 21, 0.24, 1.01),
  PulseGradientDef(2, 1, PulseQuad.bl, 17, 40, 0.0, 0.6),
  PulseGradientDef(3, 2, PulseQuad.tl, 13, 32, -0.01, 0.28),
];

/// Card 5 outward bloom — wider/blurred halo (7 gradients).
const List<PulseGradientDef> pulseOuterBloom = [
  PulseGradientDef(0, 1, PulseQuad.tl, 110, 30, 0.27, 0.03),
  PulseGradientDef(6, 2, PulseQuad.tr, 100, 20, 0.73, 0.01),
  PulseGradientDef(7, 3, PulseQuad.tr, 26, 62, 1.0, 0.33),
  PulseGradientDef(8, 1, PulseQuad.br, 30, 56, 1.01, 0.72),
  PulseGradientDef(4, 2, PulseQuad.br, 120, 22, 0.67, 0.99),
  PulseGradientDef(1, 3, PulseQuad.bl, 88, 32, 0.24, 0.99),
  PulseGradientDef(2, 1, PulseQuad.bl, 28, 58, 0.0, 0.6),
];
