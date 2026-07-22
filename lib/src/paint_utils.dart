// Low-level canvas helpers translating CSS gradient/mask idioms to Skia.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/animation.dart' show Curve, Curves;
import 'package:flutter/rendering.dart';

/// A CSS gradient color stop (offset 0..1).
class GradStop {
  const GradStop(this.color, this.offset);
  final Color color;
  final double offset;
}

Color transparentOf(Color c) => c.withAlpha(0);

/// Shader for `radial-gradient(ellipse rx ry at cx cy, ...stops)`.
/// The gradient is a unit circle scaled to (rx, ry) — identical falloff to CSS.
ui.Shader ellipseShader(
  double cx,
  double cy,
  double rx,
  double ry,
  List<Color> colors,
  List<double> stops,
) {
  final m = Matrix4.identity()
    ..translate(cx, cy)
    ..scale(rx, ry, 1.0);
  return ui.Gradient.radial(
    Offset.zero,
    1,
    colors,
    stops,
    TileMode.clamp,
    m.storage,
  );
}

/// Draws one elliptical gradient blob over [bounds]. Skipped when the radii
/// are non-positive (degenerate geometry).
void drawEllipse(
  Canvas canvas,
  Rect bounds,
  double cx,
  double cy,
  double rx,
  double ry,
  List<Color> colors,
  List<double> stops, {
  BlendMode blendMode = BlendMode.srcOver,
}) {
  if (rx <= 0 || ry <= 0) return;
  final paint = Paint()
    ..shader = ellipseShader(cx, cy, rx, ry, colors, stops)
    ..blendMode = blendMode;
  canvas.drawRect(bounds, paint);
}

/// Simple `color → transparent` blob (the most common CSS pattern here).
void drawBlob(
  Canvas canvas,
  Rect bounds,
  double cx,
  double cy,
  double rx,
  double ry,
  Color color,
) {
  drawEllipse(
      canvas, bounds, cx, cy, rx, ry, [color, transparentOf(color)], [0, 1]);
}

/// Shader for `conic-gradient(from fromDeg at center, ...stops)`.
/// CSS conic gradients start pointing up and sweep clockwise; Skia sweep
/// gradients start at the +x axis, hence the -90° correction.
ui.Shader conicShader(
  Offset center,
  double fromDeg,
  List<GradStop> stops,
) {
  final m = Matrix4.identity()
    ..translate(center.dx, center.dy)
    ..rotateZ((fromDeg - 90) * math.pi / 180)
    ..translate(-center.dx, -center.dy);
  return ui.Gradient.sweep(
    center,
    [for (final s in stops) s.color],
    [for (final s in stops) s.offset],
    TileMode.clamp,
    0,
    math.pi * 2,
    m.storage,
  );
}

void drawConic(
  Canvas canvas,
  Rect bounds,
  double fromDeg,
  List<GradStop> stops, {
  BlendMode blendMode = BlendMode.srcOver,
}) {
  final paint = Paint()
    ..shader = conicShader(bounds.center, fromDeg, stops)
    ..blendMode = blendMode;
  canvas.drawRect(bounds, paint);
}

/// The border-ring path: outer rounded rect minus the inner one — the Skia
/// equivalent of the CSS `padding + mask-composite: exclude` ring trick.
Path ringPath(Rect rect, double radius, double borderWidth) {
  final outer = RRect.fromRectAndRadius(rect, Radius.circular(radius));
  final innerRadius = math.max(0.0, radius - borderWidth);
  final inner = RRect.fromRectAndRadius(
      rect.deflate(borderWidth), Radius.circular(innerRadius));
  return Path.combine(
    PathOperation.difference,
    Path()..addRRect(outer),
    Path()..addRRect(inner),
  );
}

/// Vertical edge-frame mask: `linear-gradient(white, transparent 28px,
/// transparent calc(100% - 28px), white)`.
ui.Shader verticalEdgeMask(Rect rect, double fade) {
  final f = (fade / rect.height).clamp(0.0, 0.5);
  return ui.Gradient.linear(
    rect.topLeft,
    rect.bottomLeft,
    const [Color(0xFFFFFFFF), Color(0x00FFFFFF), Color(0x00FFFFFF), Color(0xFFFFFFFF)],
    [0, f, 1 - f, 1],
  );
}

/// Horizontal edge-frame mask (`to right` variant of the same gradient).
ui.Shader horizontalEdgeMask(Rect rect, double fade) {
  final f = (fade / rect.width).clamp(0.0, 0.5);
  return ui.Gradient.linear(
    rect.topLeft,
    rect.topRight,
    const [Color(0xFFFFFFFF), Color(0x00FFFFFF), Color(0x00FFFFFF), Color(0xFFFFFFFF)],
    [0, f, 1 - f, 1],
  );
}

/// CSS `box-shadow: inset 0 0 <blur> <spread> color` inside [rrect].
void drawInnerShadow(
  Canvas canvas,
  RRect rrect,
  double blur,
  double spread,
  Color color,
) {
  if (color.alpha == 0) return;
  canvas.save();
  canvas.clipRRect(rrect);
  final outer = Path()..addRect(rrect.outerRect.inflate(blur + spread + 8));
  final inner = Path()..addRRect(rrect.deflate(spread));
  final shadowPath = Path.combine(PathOperation.difference, outer, inner);
  final paint = Paint()
    ..color = color
    // box-shadow blur radius ≈ 2σ.
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur / 2);
  canvas.drawPath(shadowPath, paint);
  canvas.restore();
}

/// Piecewise-linear/eased keyframe track (CSS @keyframes equivalent).
/// [frames] maps a 0..1 cycle position to a value; the timing function is
/// applied per segment, matching CSS animation semantics.
double sampleKeyframes(
  double t01,
  List<List<double>> frames, {
  Curve curve = Curves.linear,
}) {
  if (t01 <= frames.first[0]) return frames.first[1];
  if (t01 >= frames.last[0]) return frames.last[1];
  for (var i = 0; i < frames.length - 1; i++) {
    final a = frames[i];
    final b = frames[i + 1];
    if (t01 >= a[0] && t01 <= b[0]) {
      final span = b[0] - a[0];
      final p = span <= 0 ? 0.0 : (t01 - a[0]) / span;
      return a[1] + (b[1] - a[1]) * curve.transform(p);
    }
  }
  return frames.last[1];
}

/// CSS 0%/50%/100% ping-pong hue keyframes (`-range → +range → -range`)
/// with per-segment ease-in-out — used by the rotate/line hue-shift.
double pingPongHue(double t01, double range, {Curve curve = Curves.easeInOut}) {
  final p = t01 < 0.5 ? t01 * 2 : 2 - t01 * 2;
  return -range + 2 * range * curve.transform(p);
}

/// CSS clamps oversized border radii to the box; RRect does not, so clamp.
/// Passing e.g. 999 yields a stadium/pill shape, like on the web.
double clampRadius(double radius, Size size) =>
    math.min(radius, size.shortestSide / 2);
