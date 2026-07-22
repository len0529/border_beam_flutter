// Pulse family — port of generatePulseInnerVariantCSS (v5 Card 4) and
// generatePulseOuterVariantCSS (v5 Card 5).
//
// The breathing layers repaint from the shared frame clock (throttled to
// ~30fps by the widget); the heavy blurred bloom layers are FROZEN at the
// breathing time-average and painted once into a RepaintBoundary raster —
// only the cheap hue-rotate color filter varies per frame (the same
// optimization the web version uses).
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'config.dart';
import 'filters.dart';
import 'paint_utils.dart';
import 'presets.dart';
import 'pulse.dart';
import 'types.dart';

/// Reference element size the Pulse Outside glow geometry was authored for.
const _refWidth = 350.0;
const _refHeight = 140.0;
const _minGlowScale = 0.35;
const _maxGlowScale = 4.0;

double _clampScale(double v) => v.clamp(_minGlowScale, _maxGlowScale);

/// Per-axis glow scale so the halo grows/shrinks to fit any wrapped element.
Offset glowScale(Size size) => Offset(
      _clampScale(size.width / _refWidth),
      _clampScale(size.height / _refHeight),
    );

/// Draws one breathing pulse blob (port of pulseGrad).
void _pulseBlob(
  Canvas canvas,
  Rect rect,
  Size box,
  PulseValues v,
  Color color,
  double w,
  double h,
  int region,
  PulseQuad quad,
  double x,
  double y, {
  double sx = 1,
  double sy = 1,
  double boost = 1,
}) {
  final r = region - 1;
  drawBlob(
    canvas,
    rect,
    x * box.width + v.bx[r],
    y * box.height + v.by[r],
    w * v.bw[r] * sx * boost,
    h * v.bh[r] * v.bgh * sy * boost,
    color.withOpacity(v.bop[quad]!.clamp(0.0, 1.0)),
  );
}

/// Pulse Inner foreground: the colorful perimeter ring (z2) and the inner
/// perimeter glow with corner accents (z1), both clipped inside the element.
class PulseInnerPainter extends CustomPainter {
  PulseInnerPainter({
    required this.config,
    required this.bank,
    required this.time,
    required this.fade,
  }) : super(repaint: Listenable.merge([time, fade]));

  final BeamConfig config;
  final PulseOscillatorBank bank;
  final ValueListenable<double> time;
  final ValueListenable<double> fade;

  @override
  void paint(Canvas canvas, Size size) {
    final c = config;
    final fadeOp = fade.value;
    if (fadeOp <= 0 || size.isEmpty) return;

    final v = bank.sample(time.value);
    final rect = Offset.zero & size;
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(c.borderRadius));
    final ring = ringPath(rect, c.borderRadius, c.borderWidth);
    final border = colorPalettes[c.colorVariant]!.border;

    final filter = beamColorFilter(
      hueDegrees: c.staticColors ? 0 : c.hueBase + v.hueDeg,
      brightness: c.brightness,
      saturation: c.saturation,
    );

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

    // ── z1: inner perimeter glow + corner accents (::before) ───────────────
    if (innerOp > 0) {
      canvas.saveLayer(
        rect,
        Paint()
          ..color = const Color(0xFFFFFFFF).withOpacity(innerOp)
          ..colorFilter = filter,
      );
      canvas.clipRRect(rrect);
      // Corner accents sit under the palette gradients.
      final cornerColor = c.isDark ? 0xFFFFFF : 0x000000;
      final cornerAlpha = c.isDark ? 0.18 : 0.08;
      const corners = [
        [0.0, 0.0, PulseQuad.tl],
        [1.0, 0.0, PulseQuad.tr],
        [0.0, 1.0, PulseQuad.bl],
        [1.0, 1.0, PulseQuad.br],
      ];
      for (final corner in corners) {
        final q = corner[2] as PulseQuad;
        final a = (cornerAlpha * v.bop[q]!).clamp(0.0, 1.0);
        final col = Color(0x00000000 | cornerColor).withOpacity(a);
        drawEllipse(
          canvas,
          rect,
          (corner[0] as double) * size.width,
          (corner[1] as double) * size.height,
          60,
          60,
          [col, transparentOf(col)],
          const [0, 0.7],
        );
      }
      for (var i = border.length - 1; i >= 0; i--) {
        final g = border[i];
        final m = pulseRingMap[i];
        _pulseBlob(canvas, rect, size, v, g.color, pulseInnerSizes[i][0],
            pulseInnerSizes[i][1], m.region, m.quad, g.px, g.py);
      }
      // mask: edge frames (28px) — vertical + horizontal, additive.
      canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstIn);
      canvas.drawRect(rect, Paint()..shader = verticalEdgeMask(rect, 28));
      canvas.drawRect(rect, Paint()..shader = horizontalEdgeMask(rect, 28));
      canvas.restore();
      canvas.restore();
    }

    // ── z2: colorful perimeter ring (::after) ──────────────────────────────
    if (strokeOp > 0) {
      canvas.saveLayer(
        rect,
        Paint()
          ..color = const Color(0xFFFFFFFF).withOpacity(strokeOp)
          ..colorFilter = filter,
      );
      canvas.clipPath(ring);
      for (var i = border.length - 1; i >= 0; i--) {
        final g = border[i];
        final m = pulseRingMap[i];
        _pulseBlob(canvas, rect, size, v, g.color, g.w, g.h, m.region, m.quad,
            g.px, g.py);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(PulseInnerPainter oldDelegate) =>
      oldDelegate.config != config || oldDelegate.bank != bank;
}

/// Pulse Inner bloom — FROZEN gradient table masked to the 1px edge ring.
/// Painted once and cached (blur + hue applied by widget-level layers).
class PulseInnerBloomPainter extends CustomPainter {
  PulseInnerBloomPainter({required this.config, required this.frozenAlpha});

  final BeamConfig config;
  final double frozenAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final c = config;
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final ring = ringPath(rect, c.borderRadius, c.borderWidth);
    canvas.save();
    canvas.clipPath(ring);
    final border = colorPalettes[c.colorVariant]!.border;
    for (final e in pulseInnerBloom.reversed) {
      final g = border[e.ci];
      drawBlob(canvas, rect, g.px * size.width, g.py * size.height,
          e.w * c.glowBoost, e.h * c.glowBoost,
          g.color.withOpacity(frozenAlpha));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PulseInnerBloomPainter oldDelegate) =>
      oldDelegate.config != config || oldDelegate.frozenAlpha != frozenAlpha;
}

/// Pulse Outside stroke — the crisp 1px colored stroke hugging the outer edge.
class PulseOuterStrokePainter extends CustomPainter {
  PulseOuterStrokePainter({
    required this.config,
    required this.bank,
    required this.time,
    required this.fade,
  }) : super(repaint: Listenable.merge([time, fade]));

  final BeamConfig config;
  final PulseOscillatorBank bank;
  final ValueListenable<double> time;
  final ValueListenable<double> fade;

  @override
  void paint(Canvas canvas, Size size) {
    final c = config;
    final fadeOp = fade.value;
    if (fadeOp <= 0 || size.isEmpty) return;

    final v = bank.sample(time.value);
    final rect = Offset.zero & size;
    final ring = ringPath(rect, c.borderRadius, 1);
    final border = colorPalettes[c.colorVariant]!.border;
    final scale = glowScale(size);

    final strokeOp = (fadeOp *
            c.strokeOpacity *
            c.monoMul *
            c.strokeOpacityFactor *
            c.strength)
        .clamp(0.0, 1.0);
    if (strokeOp <= 0) return;

    canvas.saveLayer(
      rect,
      Paint()
        ..color = const Color(0xFFFFFFFF).withOpacity(strokeOp)
        ..colorFilter = beamColorFilter(
          hueDegrees: c.staticColors ? 0 : c.hueBase + v.hueDeg,
          brightness: c.brightness,
          saturation: c.saturation,
        ),
    );
    canvas.clipPath(ring);
    // Static hairline under the colored stroke (only when configured).
    if (c.hairlineOpacity > 0) {
      final hairRGB = c.isDark ? const Color(0xFF464646) : const Color(0xFF000000);
      canvas.drawRect(
          rect, Paint()..color = hairRGB.withOpacity(c.hairlineOpacity));
    }
    for (final e in pulseOuterCore.reversed) {
      final g = border[e.ci];
      _pulseBlob(canvas, rect, size, v, g.color, e.w, e.h, e.region, e.quad,
          e.x ?? g.px, e.y ?? g.py,
          sx: scale.dx, sy: scale.dy, boost: c.glowBoost);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PulseOuterStrokePainter oldDelegate) =>
      oldDelegate.config != config || oldDelegate.bank != bank;
}

/// Pulse Outside core — the colorful glow radiating outward behind the
/// element (CSS `::before` with `inset: -10px; z-index: -1`).
class PulseOuterCorePainter extends CustomPainter {
  PulseOuterCorePainter({
    required this.config,
    required this.bank,
    required this.time,
    required this.fade,
  }) : super(repaint: Listenable.merge([time, fade]));

  final BeamConfig config;
  final PulseOscillatorBank bank;
  final ValueListenable<double> time;
  final ValueListenable<double> fade;

  @override
  void paint(Canvas canvas, Size size) {
    final c = config;
    final fadeOp = fade.value;
    if (fadeOp <= 0 || size.isEmpty) return;

    final v = bank.sample(time.value);
    final innerOp = (fadeOp *
            c.innerOpacity *
            c.monoMul *
            c.innerOpacityFactor *
            c.strength)
        .clamp(0.0, 1.0);
    if (innerOp <= 0) return;

    final box = Size(size.width + 20, size.height + 20);
    final rect = Rect.fromLTWH(-10, -10, box.width, box.height);
    final border = colorPalettes[c.colorVariant]!.border;
    final scale = glowScale(size);
    final coreBlur = c.coreBlur ?? (c.isDark ? 3.0 : 6.0);

    canvas.saveLayer(
      rect.inflate(coreBlur * 3 + 40),
      Paint()
        ..color = const Color(0xFFFFFFFF).withOpacity(innerOp)
        ..imageFilter = ui.ImageFilter.blur(sigmaX: coreBlur, sigmaY: coreBlur)
        ..colorFilter = beamColorFilter(
          hueDegrees: c.staticColors ? 0 : c.hueBase + v.hueDeg,
          brightness: c.glowBrightness ?? c.brightness,
          saturation: c.glowSaturation ?? c.saturation,
        ),
    );
    // transform: scale(0.95, 0.9) about the pseudo-element center.
    final center = rect.center;
    canvas.translate(center.dx, center.dy);
    canvas.scale(0.95, 0.9);
    canvas.translate(-center.dx, -center.dy);
    for (final e in pulseOuterCore.reversed) {
      final g = border[e.ci];
      final r = e.region - 1;
      drawBlob(
        canvas,
        rect,
        rect.left + (e.x ?? g.px) * box.width + v.bx[r],
        rect.top + (e.y ?? g.py) * box.height + v.by[r],
        e.w * v.bw[r] * scale.dx * c.glowBoost,
        e.h * v.bh[r] * v.bgh * scale.dy * c.glowBoost,
        g.color.withOpacity(v.bop[e.quad]!.clamp(0.0, 1.0)),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PulseOuterCorePainter oldDelegate) =>
      oldDelegate.config != config || oldDelegate.bank != bank;
}

/// Pulse Outside bloom — FROZEN wide halo (CSS bloom with `inset: -30px`).
/// Painted once and cached; blur + hue applied by widget-level layers.
class PulseOuterBloomPainter extends CustomPainter {
  PulseOuterBloomPainter({required this.config, required this.frozenAlpha});

  final BeamConfig config;
  final double frozenAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final c = config;
    if (size.isEmpty) return;
    final box = Size(size.width + 60, size.height + 60);
    final rect = Rect.fromLTWH(-30, -30, box.width, box.height);
    final border = colorPalettes[c.colorVariant]!.border;
    final scale = glowScale(size);

    canvas.save();
    final center = rect.center;
    canvas.translate(center.dx, center.dy);
    canvas.scale(0.95, 0.9);
    canvas.translate(-center.dx, -center.dy);
    for (final e in pulseOuterBloom.reversed) {
      final g = border[e.ci];
      drawBlob(
        canvas,
        rect,
        rect.left + (e.x ?? g.px) * box.width,
        rect.top + (e.y ?? g.py) * box.height,
        e.w * scale.dx * c.glowBoost,
        e.h * scale.dy * c.glowBoost,
        g.color.withOpacity(frozenAlpha),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PulseOuterBloomPainter oldDelegate) =>
      oldDelegate.config != config || oldDelegate.frozenAlpha != frozenAlpha;
}

/// Frozen bloom alpha: the time-average of the breathing opacity range
/// (midpoint of `[1 - op, 1]`).
double frozenBloomAlpha(BorderBeamSize size, bool isDark, double duration) {
  final p = pulseParams(size, isDark, duration);
  return math.max(0, 1 - p.op * 0.5);
}
