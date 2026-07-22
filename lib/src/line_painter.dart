// Line variant — port of generateLineVariantCSS: a traveling glow along the
// bottom edge with breathe/spike oscillators and a spiky bloom.
import 'dart:ui' as ui;

import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'config.dart';
import 'filters.dart';
import 'paint_utils.dart';
import 'presets.dart';

// @keyframes tables ported verbatim (cycle-position → value).
const _travelX = [
  [0.0, 0.06], [0.1, 0.15], [0.2, 0.25], [0.3, 0.35], [0.4, 0.44],
  [0.5, 0.5], [0.6, 0.56], [0.7, 0.65], [0.8, 0.75], [0.9, 0.85], [1.0, 0.94],
];
const _travelW = [
  [0.0, 0.5], [0.1, 0.8], [0.2, 1.1], [0.3, 1.3], [0.4, 1.45],
  [0.5, 1.5], [0.6, 1.45], [0.7, 1.3], [0.8, 1.1], [0.9, 0.8], [1.0, 0.5],
];
const _edgeFade = [
  [0.0, 0.0], [0.125, 0.0], [0.325, 1.0], [0.675, 1.0], [0.875, 0.0],
  [1.0, 0.0],
];
const _breathe = [
  [0.0, 0.8], [0.25, 1.25], [0.55, 0.85], [0.8, 1.3], [1.0, 0.8],
];
const _spike = [
  [0.0, 0.8], [0.25, 1.3], [0.5, 0.9], [0.75, 1.4], [1.0, 0.8],
];
const _spike2 = [
  [0.0, 1.2], [0.25, 0.7], [0.5, 1.4], [0.75, 0.8], [1.0, 1.2],
];

Color _alpha(Color c, double a) => c.withValues(alpha: a);
Color _attenuate(Color c, double f) => c.withValues(alpha: c.opacity * f);

class LineBeamPainter extends CustomPainter {
  LineBeamPainter({
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
    final w = size.width;
    final h = size.height;

    final cycle = t / c.duration % 1;
    final x = sampleKeyframes(cycle, _travelX);
    final bw = sampleKeyframes(cycle, _travelW);
    final edge = sampleKeyframes(cycle, _edgeFade);
    final bh = sampleKeyframes(
        t / (c.duration * 1.3) % 1, _breathe, curve: Curves.easeInOut);
    final spike = sampleKeyframes(
        t / (c.duration * 1.33) % 1, _spike, curve: Curves.easeInOut);
    final spike2 = sampleKeyframes(
        t / (c.duration * 1.7) % 1, _spike2, curve: Curves.easeInOut);

    if (edge <= 0) return;

    final hue = c.hueBase + pingPongHue(t / 12 % 1, c.hueRange);
    final bloomHue = c.hueBase + pingPongHue(t / 8 % 1, c.hueRange + 10);

    final radius = clampRadius(c.borderRadius, size);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final ring = ringPath(rect, radius, c.borderWidth);
    final beamX = x * w;

    final strokeOp =
        (fadeOp * edge * c.strokeOpacity * c.strokeOpacityFactor * c.strength)
            .clamp(0.0, 1.0);
    final innerOp =
        (fadeOp * edge * c.innerOpacity * c.innerOpacityFactor * c.strength)
            .clamp(0.0, 1.0);
    final bloomOp =
        (fadeOp * edge * c.bloomOpacity * c.bloomOpacityFactor * c.strength)
            .clamp(0.0, 1.0);

    final layerFilter = c.staticColors
        ? null
        : beamColorFilter(
            hueDegrees: hue,
            brightness: c.brightness,
            saturation: c.saturation);

    // The beam window mask shared by the stroke and inner layers.
    void drawWindowMask(Canvas canvas) {
      drawEllipse(
        canvas,
        rect.inflate(8),
        beamX,
        h,
        78 * bw,
        60 * bh,
        [
          const Color(0xFFFFFFFF),
          const Color(0x80FFFFFF),
          const Color(0x00FFFFFF),
        ],
        const [0, 0.45, 1],
      );
    }

    // ── z1: inner glow layer ───────────────────────────────────────────────
    if (innerOp > 0) {
      canvas.saveLayer(
        rect,
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: innerOp)
          ..colorFilter = layerFilter,
      );
      canvas.clipRRect(rrect);
      final inner = config.palettes.lineInner;
      for (final g in inner.reversed) {
        drawBlob(canvas, rect, beamX + g.offsetX, h - g.offsetY.abs(),
            g.sizeW * bw, g.sizeH * bh, g.color);
      }
      drawInnerShadow(canvas, rrect, 9, 1, c.innerShadow);
      // mask: window ∩ (vertical + horizontal edge frames)
      canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstIn);
      canvas.drawRect(rect, Paint()..shader = verticalEdgeMask(rect, 28));
      canvas.drawRect(rect, Paint()..shader = horizontalEdgeMask(rect, 28));
      canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstIn);
      drawWindowMask(canvas);
      canvas.restore();
      canvas.restore();
      canvas.restore();
    }

    // ── z2: colorful stroke ring ───────────────────────────────────────────
    if (strokeOp > 0) {
      canvas.saveLayer(
        rect,
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: strokeOp)
          ..colorFilter = layerFilter,
      );
      canvas.clipPath(ring);
      final palette = config.palettes.line;
      final blobs = c.isDark ? palette.dark : palette.light;
      for (final g in blobs.reversed) {
        drawBlob(canvas, rect, beamX + g.offsetX, h + g.offsetY,
            g.sizeW * bw, g.sizeH * bh, g.color);
      }
      // White traveling highlight (topmost background layer).
      if (c.isDark) {
        drawEllipse(
          canvas, rect, beamX, h + 2, 24 * bw, 28 * bh,
          const [Color(0x61FFFFFF), Color(0x1FFFFFFF), Color(0x00FFFFFF)],
          const [0, 0.3, 0.65],
        );
      } else {
        drawEllipse(
          canvas, rect, beamX, h + 2, 35 * bw, 28 * bh,
          const [Color(0x99000000), Color(0x40000000), Color(0x00000000)],
          const [0, 0.35, 0.7],
        );
      }
      canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstIn);
      drawWindowMask(canvas);
      canvas.restore();
      canvas.restore();
    }

    // ── z3: spiky bloom ────────────────────────────────────────────────────
    if (bloomOp > 0) {
      final bloomPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: bloomOp);
      if (c.isMono) {
        bloomPaint.imageFilter = ui.ImageFilter.blur(
            sigmaX: 6, sigmaY: 6, tileMode: TileMode.decal);
      } else if (!c.staticColors) {
        bloomPaint
          ..imageFilter = ui.ImageFilter.blur(
              sigmaX: 8, sigmaY: 8, tileMode: TileMode.decal)
          ..colorFilter = beamColorFilter(
              hueDegrees: bloomHue,
              brightness: c.brightness,
              saturation: c.saturation);
      }
      canvas.save();
      canvas.clipRRect(rrect);
      canvas.saveLayer(rect.inflate(24), bloomPaint);
      _drawBloomGradients(canvas, rect, spike, spike2, bh, bw, beamX);
      // mask window
      canvas.saveLayer(rect.inflate(24), Paint()..blendMode = BlendMode.dstIn);
      drawEllipse(
        canvas,
        rect.inflate(24),
        beamX,
        h,
        84 * bw,
        110 * bh,
        const [Color(0xFFFFFFFF), Color(0x80FFFFFF), Color(0x00FFFFFF)],
        const [0, 0.35, 1],
      );
      canvas.restore();
      canvas.restore();
      canvas.restore();
    }
  }

  /// Port of getLineBloomGradients — fixed spikes at 8/22/36/50/64/78/92%
  /// plus the traveling glow dot and ambient wash.
  void _drawBloomGradients(Canvas canvas, Rect rect, double spike,
      double spike2, double bh, double bw, double beamX) {
    final c = config;
    final w = rect.width;
    final h = rect.height;
    final palette = config.palettes.border;
    final spikeColors = c.isDark ? palette.spike : palette.spikeLt;
    final bloomPalette = config.palettes.lineBloom;
    final bloomData = c.isDark ? bloomPalette.dark : bloomPalette.light;
    final isMono = c.isMono;

    // Mono uses uniform gray, so thin full-opacity spikes look like harsh
    // bars — attenuate and widen them into soft glows.
    final att = isMono ? 0.14 : 1.0;
    final sc1 = isMono ? _attenuate(spikeColors.primary, 0.14) : spikeColors.primary;
    final sc1Mid =
        isMono ? _attenuate(spikeColors.primary, 0.09) : spikeColors.primary;
    final sc2 =
        isMono ? _attenuate(spikeColors.secondary, 0.12) : spikeColors.secondary;
    final sc2Mid = isMono
        ? _alpha(spikeColors.secondary, 0.06)
        : _alpha(spikeColors.secondary, 0.49);

    final spikes = [
      for (final s in bloomData.spikes)
        isMono
            ? BloomSpike(_attenuate(s.color1, att), _attenuate(s.color2, att * 0.7))
            : s,
    ];

    final thinW1 = isMono ? 12.0 : 0.8;
    final thinW2 = isMono ? 14.0 : 2.0;
    final thinW3 = isMono ? 12.0 : 1.2;
    final thinW4 = isMono ? 10.0 : 0.6;
    final thinH1 = isMono ? 42.0 : 92.0;
    final thinH2 = isMono ? 38.0 : 72.0;
    final thinH3 = isMono ? 40.0 : 85.0;
    final thinH4 = isMono ? 32.0 : 60.0;
    final thinLW = isMono ? 12.0 : 1.0;

    void spikeGrad(double px, double yOff, double rw, double rh, Color c1,
        Color c2, double midStop, double endStop) {
      drawEllipse(canvas, rect, px * w, h - yOff, rw, rh,
          [c1, c2, transparentOf(c2)], [0, midStop, endStop]);
    }

    if (c.isDark) {
      // Painted bottom-up (CSS list order = topmost first).
      final glowDotC = isMono
          ? const Color(0x80FFFFFF)
          : const Color(0xFFFFFFFF);
      final glowDot20 =
          isMono ? const Color(0x73FFFFFF) : const Color(0xE6FFFFFF);
      final glowDot50 =
          isMono ? const Color(0x40FFFFFF) : const Color(0x80FFFFFF);
      final glowAmbC =
          isMono ? const Color(0x26FFFFFF) : const Color(0x4DFFFFFF);
      final glowAmb25 =
          isMono ? const Color(0x0FFFFFFF) : const Color(0x1FFFFFFF);
      final glowAmb55 =
          isMono ? const Color(0x04FFFFFF) : const Color(0x08FFFFFF);

      // 9. ambient wash
      drawEllipse(canvas, rect, beamX, h, 42 * bw, 40 * bh,
          [glowAmbC, glowAmb25, glowAmb55, const Color(0x00FFFFFF)],
          const [0, 0.25, 0.55, 0.8]);
      // 8. traveling glow dot
      drawEllipse(canvas, rect, beamX, h + 1, 21 * spike, 15 * spike2,
          [glowDotC, glowDot20, glowDot50, const Color(0x00FFFFFF)],
          const [0, 0.2, 0.5, 1]);
      // 7..3: fixed spikes (reverse list order)
      spikeGrad(0.92, 3, thinW4 * (2 - spike), thinH4 * bh, spikes[4].color1,
          spikes[4].color2, 0.42, 0.91);
      spikeGrad(0.78, 2, 7 * spike, 45 * bh, spikes[3].color1,
          spikes[3].color2, 0.48, 0.94);
      spikeGrad(0.64, 4, thinW3 * (2 - spike2), thinH3 * bh, spikes[2].color1,
          spikes[2].color2, 0.35, 0.89);
      spikeGrad(0.5, 2, 14 * spike2, 28 * bh, spikes[1].color1,
          spikes[1].color2, 0.55, 0.96);
      spikeGrad(0.36, 3, thinW2 * (2 - spike), thinH2 * bh, spikes[0].color1,
          spikes[0].color2, 0.4, 0.9);
      // 2. secondary accent spike
      spikeGrad(0.22, 4, 10 * spike2, 35 * bh, sc2, sc2Mid, 0.5, 0.95);
      // 1. primary accent spike
      spikeGrad(0.08, 2, thinW1 * spike, thinH1 * bh, sc1, sc1Mid, 0.3, 0.88);
    } else {
      final sc1Lt = isMono
          ? _attenuate(spikeColors.primary, 0.11)
          : _alpha(spikeColors.primary, 0.85);
      final sc2Lt = isMono
          ? _attenuate(spikeColors.secondary, 0.09)
          : _alpha(spikeColors.secondary, 0.7);

      // 8. dark ambient shadow wash
      drawEllipse(canvas, rect, beamX, h, 50 * bw, 32 * bh,
          const [Color(0x80000000), Color(0x2E000000), Color(0x08000000), Color(0x00000000)],
          const [0, 0.3, 0.6, 0.85]);
      // 7..3
      spikeGrad(0.92, 3, thinLW * (2 - spike), thinH4 * bh, spikes[4].color1,
          spikes[4].color2, 0.42, 0.91);
      spikeGrad(0.78, 2, 7 * spike, 45 * bh, spikes[3].color1,
          spikes[3].color2, 0.48, 0.94);
      spikeGrad(0.64, 4, thinW3 * (2 - spike2), thinH3 * bh, spikes[2].color1,
          spikes[2].color2, 0.35, 0.89);
      spikeGrad(0.5, 2, 14 * spike2, 28 * bh, spikes[1].color1,
          spikes[1].color2, 0.55, 0.96);
      spikeGrad(0.36, 3, thinW2 * (2 - spike), thinH2 * bh, spikes[0].color1,
          spikes[0].color2, 0.4, 0.9);
      // 2, 1
      spikeGrad(0.22, 4, 10 * spike2, 35 * bh, sc2, sc2Lt, 0.5, 0.95);
      spikeGrad(0.08, 2, thinW1 * spike, thinH1 * bh, sc1, sc1Lt, 0.3, 0.88);
    }
  }

  @override
  bool shouldRepaint(LineBeamPainter oldDelegate) =>
      oldDelegate.config != config ||
      oldDelegate.time != time ||
      oldDelegate.fade != fade;
}
