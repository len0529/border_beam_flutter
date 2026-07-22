// CSS filter function equivalents.
//
// CSS shorthand filters (hue-rotate / brightness / saturate) are defined as
// color matrices applied in sRGB space — exactly what [ColorFilter.matrix]
// does — so these produce pixel-identical results to the web version.
import 'dart:math' as math;
import 'dart:ui' show ColorFilter;

/// 4x5 identity color matrix.
const List<double> identityMatrix = [
  1, 0, 0, 0, 0,
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0,
];

/// CSS `hue-rotate(deg)` matrix (Filter Effects spec).
List<double> hueRotateMatrix(double degrees) {
  final rad = degrees * math.pi / 180;
  final c = math.cos(rad);
  final s = math.sin(rad);
  return [
    0.213 + c * 0.787 - s * 0.213,
    0.715 - c * 0.715 - s * 0.715,
    0.072 - c * 0.072 + s * 0.928,
    0,
    0,
    0.213 - c * 0.213 + s * 0.143,
    0.715 + c * 0.285 + s * 0.140,
    0.072 - c * 0.072 - s * 0.283,
    0,
    0,
    0.213 - c * 0.213 - s * 0.787,
    0.715 - c * 0.715 + s * 0.715,
    0.072 + c * 0.928 + s * 0.072,
    0,
    0,
    0, 0, 0, 1, 0,
  ];
}

/// CSS `brightness(b)` matrix.
List<double> brightnessMatrix(double b) {
  return [
    b, 0, 0, 0, 0,
    0, b, 0, 0, 0,
    0, 0, b, 0, 0,
    0, 0, 0, 1, 0,
  ];
}

/// CSS `saturate(s)` matrix (Filter Effects spec).
List<double> saturateMatrix(double s) {
  return [
    0.213 + 0.787 * s, 0.715 - 0.715 * s, 0.072 - 0.072 * s, 0, 0,
    0.213 - 0.213 * s, 0.715 + 0.285 * s, 0.072 - 0.072 * s, 0, 0,
    0.213 - 0.213 * s, 0.715 - 0.715 * s, 0.072 + 0.928 * s, 0, 0,
    0, 0, 0, 1, 0,
  ];
}

/// Compose two 4x5 color matrices: result applies [inner] first, then [outer]
/// (i.e. `result = outer * inner`).
List<double> composeMatrices(List<double> outer, List<double> inner) {
  final out = List<double>.filled(20, 0);
  for (var row = 0; row < 4; row++) {
    for (var col = 0; col < 5; col++) {
      var v = 0.0;
      for (var k = 0; k < 4; k++) {
        v += outer[row * 5 + k] * inner[k * 5 + col];
      }
      if (col == 4) v += outer[row * 5 + 4];
      out[row * 5 + col] = v;
    }
  }
  return out;
}

/// CSS `filter: hue-rotate(hue) brightness(b) saturate(s)` — functions apply
/// left-to-right, so hue first, then brightness, then saturation.
ColorFilter beamColorFilter({
  required double hueDegrees,
  required double brightness,
  required double saturation,
}) {
  var m = hueDegrees == 0 ? identityMatrix : hueRotateMatrix(hueDegrees);
  if (brightness != 1) m = composeMatrices(brightnessMatrix(brightness), m);
  if (saturation != 1) m = composeMatrices(saturateMatrix(saturation), m);
  return ColorFilter.matrix(m);
}
