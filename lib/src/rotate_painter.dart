// Rotate family (`sm` / `md`) — port of generateBorderVariantCSS /
// generateSmallVariantCSS: a conic-masked colorful stroke ring, an inner glow
// masked to the edges, and a blurred white bloom arc, all spinning together.
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'config.dart';
import 'filters.dart';
import 'paint_utils.dart';
import 'types.dart';

/// White traveling-beam conic gradient stops (dark theme).
List<GradStop> _whiteConic(bool isDark) {
  Color c(double a) => isDark
      ? Color.fromRGBO(255, 255, 255, a)
      : Color.fromRGBO(0, 0, 0, a);
  final alphas = isDark
      ? const [0.1, 0.3, 0.6, 0.75, 0.6, 0.3, 0.1]
      : const [0.08, 0.2, 0.4, 0.55, 0.4, 0.2, 0.08];
  return [
    GradStop(c(0), 0),
    GradStop(c(0), 0.54),
    GradStop(c(alphas[0]), 0.57),
    GradStop(c(alphas[1]), 0.60),
    GradStop(c(alphas[2]), 0.63),
    GradStop(c(alphas[3]), 0.66),
    GradStop(c(alphas[4]), 0.69),
    GradStop(c(alphas[5]), 0.72),
    GradStop(c(alphas[6]), 0.75),
    GradStop(c(0), 0.78),
    GradStop(c(0), 1),
  ];
}

/// The rotating beam window mask (shared by the stroke and inner layers).
List<GradStop> _beamMask() {
  const w = Color(0xFFFFFFFF);
  Color a(double v) => Color.fromRGBO(255, 255, 255, v);
  return [
    GradStop(a(0), 0),
    GradStop(a(0), 0.30),
    GradStop(a(0.1), 0.36),
    GradStop(a(0.35), 0.44),
    const GradStop(w, 0.52),
    const GradStop(w, 0.80),
    GradStop(a(0.35), 0.86),
    GradStop(a(0.1), 0.92),
    GradStop(a(0), 0.95),
    GradStop(a(0), 1),
  ];
}

/// Wider mask used by the small variant's inner layer.
List<GradStop> _smallInnerMask() {
  const w = Color(0xFFFFFFFF);
  Color a(double v) => Color.fromRGBO(255, 255, 255, v);
  return [
    GradStop(a(0), 0),
    GradStop(a(0), 0.22),
    GradStop(a(0.12), 0.28),
    GradStop(a(0.4), 0.36),
    const GradStop(w, 0.46),
    const GradStop(w, 0.82),
    GradStop(a(0.4), 0.88),
    GradStop(a(0.12), 0.94),
    GradStop(a(0), 0.97),
    GradStop(a(0), 1),
  ];
}

/// The narrow bright bloom arc.
List<GradStop> _bloomConic(bool isDark) {
  Color c(double a) => isDark
      ? Color.fromRGBO(255, 255, 255, a)
      : Color.fromRGBO(0, 0, 0, a);
  final alphas = isDark
      ? const [0.03, 0.08, 0.2, 0.45, 0.85, 0.85, 0.45, 0.2, 0.08, 0.03]
      : const [0.02, 0.08, 0.2, 0.4, 0.6, 0.6, 0.4, 0.2, 0.08, 0.02];
  const offsets = [0.62, 0.65, 0.67, 0.69, 0.70, 0.705, 0.715, 0.73, 0.75, 0.78];
  return [
    GradStop(c(0), 0),
    GradStop(c(0), 0.58),
    for (var i = 0; i < offsets.length; i++) GradStop(c(alphas[i]), offsets[i]),
    GradStop(c(0), 0.82),
  ];
}

class RotateBeamPainter extends CustomPainter {
  RotateBeamPainter({
    required this.config,
    required this.time,
    required this.fade,
  }) : super(repaint: Listenable.merge([time, fade]));

  final BeamConfig config;
  final ValueListenable<double> time;
  final ValueListenable<double> fade;

  @override
  void paint(Canvas canvas, Size size) {
    final c = config;
    final t = time.value;
    final fadeOp = fade.value;
    if (fadeOp <= 0 || size.isEmpty) return;

    final rect = Offset.zero & size;
    final angle = (t / c.duration % 1) * 360;
    final hue = c.staticColors
        ? c.hueBase
        : c.hueBase + pingPongHue(t / 12 % 1, c.hueRange);

    final radius = clampRadius(c.borderRadius, size);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final ring = ringPath(rect, radius, c.borderWidth);
    final isSm = c.size == BorderBeamSize.sm;

    final strokeOp = (fadeOp *
            c.strokeOpacity *
            c.monoMul *
            c.strokeOpacityFactor *
            c.strength)
        .clamp(0.0, 1.0);
    final innerOp = (fadeOp *
            c.innerOpacity *
            c.monoMul *
            c.innerOpacityFactor *
            c.strength)
        .clamp(0.0, 1.0);
    final bloomOp = (fadeOp *
            c.bloomOpacity *
            c.monoMul *
            c.bloomOpacityFactor *
            c.strength)
        .clamp(0.0, 1.0);

    // The stroke/inner filter comes from the hue-shift animation; with static
    // colors the CSS emits no filter on those layers at all.
    final layerFilter = c.staticColors
        ? null
        : beamColorFilter(
            hueDegrees: hue,
            brightness: c.brightness,
            saturation: c.saturation);

    // ── z1: inner glow layer (::before) ────────────────────────────────────
    if (innerOp > 0) {
      canvas.saveLayer(
        rect,
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: innerOp)
          ..colorFilter = layerFilter,
      );
      canvas.clipRRect(rrect);
      if (isSm) {
        final inner = c.palettes.small.inner;
        for (final g in inner.reversed) {
          drawBlob(canvas, rect, g.px * size.width, g.py * size.height, g.w,
              g.h, g.color);
        }
        drawInnerShadow(canvas, rrect, 5, 1, c.innerShadow);
      } else {
        // md inner gradients: palette colors at 0.45 alpha (0.225 for mono),
        // sizes shrunk to 90%.
        final baseOpacity = c.isMono ? 0.225 : 0.45;
        final border = c.palettes.border.border;
        for (final g in border.reversed) {
          drawBlob(
            canvas,
            rect,
            g.px * size.width,
            g.py * size.height,
            (g.w * 0.9).roundToDouble(),
            (g.h * 0.9).roundToDouble(),
            g.color.withValues(alpha: baseOpacity),
          );
        }
        drawInnerShadow(canvas, rrect, 9, 1, c.innerShadow);
      }
      // Mask: beam window (∩ edge frames for md).
      canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstIn);
      if (isSm) {
        drawConic(canvas, rect, angle, _smallInnerMask());
      } else {
        canvas.drawRect(rect, Paint()..shader = verticalEdgeMask(rect, 28));
        canvas.drawRect(rect, Paint()..shader = horizontalEdgeMask(rect, 28));
        canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstIn);
        drawConic(canvas, rect, angle, _beamMask());
        canvas.restore();
      }
      canvas.restore();
      canvas.restore();
    }

    // ── z2: colorful stroke ring (::after) ─────────────────────────────────
    if (strokeOp > 0) {
      canvas.saveLayer(
        rect,
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: strokeOp)
          ..colorFilter = layerFilter,
      );
      canvas.clipPath(ring);
      final border =
          isSm ? c.palettes.small.border : c.palettes.border.border;
      for (final g in border.reversed) {
        drawBlob(canvas, rect, g.px * size.width, g.py * size.height, g.w, g.h,
            g.color);
      }
      drawConic(canvas, rect, angle, _whiteConic(c.isDark));
      canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstIn);
      drawConic(canvas, rect, angle, _beamMask());
      canvas.restore();
      canvas.restore();
    }

    // ── z3: blurred bloom arc ──────────────────────────────────────────────
    if (bloomOp > 0) {
      canvas.save();
      canvas.clipRRect(rrect); // clip-path applies AFTER the blur filter
      canvas.saveLayer(
        rect.inflate(24),
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: bloomOp)
          ..imageFilter = ui.ImageFilter.blur(
              sigmaX: 8, sigmaY: 8, tileMode: TileMode.decal)
          ..colorFilter = beamColorFilter(
              hueDegrees: 0,
              brightness: c.brightness,
              saturation: c.saturation),
      );
      canvas.clipPath(ring);
      drawConic(canvas, rect, angle, _bloomConic(c.isDark));
      canvas.restore();
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(RotateBeamPainter oldDelegate) =>
      oldDelegate.config != config ||
      oldDelegate.time != time ||
      oldDelegate.fade != fade;
}
