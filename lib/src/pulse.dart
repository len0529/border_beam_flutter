// Pulse breathing driver — direct port of pulseParams / pulseOscillatorDefs /
// the shared rAF loop's oscillator math from the React package.
import 'dart:math' as math;

import 'presets.dart';
import 'types.dart';

/// Cosine ease-in-out factor in [0, 1]: 0 at phase 0/1, 1 at phase 0.5.
double _pingPong(double phase) => (1 - math.cos(2 * math.pi * phase)) / 2;

class PulseOscillator {
  const PulseOscillator(this.a, this.b, this.period, [this.delay = 0]);
  final double a;
  final double b;
  final double period;
  final double delay;

  /// Value at time [t] seconds — ping-pongs between [a] and [b].
  double at(double t) => a + (b - a) * _pingPong((t - delay) / period);
}

/// Theme/size/duration-tuned breathing parameters.
class PulseParams {
  const PulseParams({
    required this.sp,
    required this.dr,
    required this.op,
    required this.gh,
    required this.bs,
    required this.ss,
    required this.ghs,
    required this.huePeriod,
  });

  final double sp;
  final double dr;
  final double op;
  final double gh;
  final double bs;
  final double ss;
  final double ghs;

  /// Full hue revolution period (seconds) — colors continuously cycle.
  final double huePeriod;
}

PulseParams pulseParams(BorderBeamSize size, bool isDark, double duration) {
  final durScale = duration / 2.3;
  if (size == BorderBeamSize.pulseInner) {
    return PulseParams(
      sp: 0.28,
      dr: isDark ? 33 : 40,
      op: isDark ? 0.48 : 0.45,
      gh: isDark ? 0.34 : 0.22,
      bs: (isDark ? 1.9 : 2.6) * durScale,
      ss: (isDark ? 2.6 : 4.6) * durScale,
      ghs: (isDark ? 2.4 : 5.5) * durScale,
      huePeriod: 16,
    );
  }
  return PulseParams(
    sp: isDark ? 0.28 : 0.36,
    dr: isDark ? 14 : 19,
    op: isDark ? 0.46 : 0,
    gh: isDark ? 0.16 : 0.58,
    bs: (isDark ? 2.3 : 3.7) * durScale,
    ss: (isDark ? 6.4 : 4.6) * durScale,
    ghs: (isDark ? 2.4 : 3.8) * durScale,
    huePeriod: 14,
  );
}

/// The live values sampled from the oscillator bank for one frame.
class PulseValues {
  PulseValues({
    required this.bw,
    required this.bh,
    required this.bx,
    required this.by,
    required this.bgh,
    required this.bop,
    required this.hueDeg,
  });

  /// Per-region (index 0..2 for g1..g3) width/height multipliers.
  final List<double> bw;
  final List<double> bh;

  /// Per-region drift in px.
  final List<double> bx;
  final List<double> by;

  /// Global height oscillator.
  final double bgh;

  /// Per-quadrant opacity.
  final Map<PulseQuad, double> bop;

  /// Continuous hue rotation in degrees (0 when colors are static).
  final double hueDeg;
}

/// Oscillator bank for one pulse instance (matches the former CSS keyframes).
class PulseOscillatorBank {
  PulseOscillatorBank(PulseParams p, {required this.hueEnabled})
      : _p = p,
        _bw = [
          PulseOscillator(1 - p.sp, 1 + p.sp * 1.1, p.ss * 0.9),
          PulseOscillator(1 + p.sp, 1 - p.sp * 0.85, p.ss * 1.1),
          PulseOscillator(1 - p.sp * 0.6, 1 + p.sp * 1.15, p.ss * 0.98),
        ],
        _bh = [
          PulseOscillator(1 + p.sp * 0.9, 1 - p.sp * 0.85, p.ss * 1.26),
          PulseOscillator(1 - p.sp * 0.8, 1 + p.sp * 1.05, p.ss * 0.81),
          PulseOscillator(1 + p.sp * 0.75, 1 - p.sp, p.ss * 1.4),
        ],
        _bx = [
          PulseOscillator(-p.dr, p.dr * 0.9, p.bs * 1.6),
          PulseOscillator(p.dr * 0.8, -p.dr * 0.9, p.bs * 1.88),
          PulseOscillator(-p.dr * 0.6, p.dr, p.bs * 1.45),
        ],
        _by = [
          PulseOscillator(p.dr * 0.55, -p.dr * 0.7, p.bs * 1.6),
          PulseOscillator(-p.dr, p.dr * 0.65, p.bs * 1.88),
          PulseOscillator(-p.dr * 0.85, p.dr * 0.45, p.bs * 1.45),
        ],
        _bgh = PulseOscillator(1 - p.gh, 1 + p.gh, p.ghs),
        _bop = {
          PulseQuad.tl: PulseOscillator(1 - p.op, 1, p.bs),
          PulseQuad.tr: PulseOscillator(1 - p.op, 1, p.bs * 1.32, p.bs * 0.28),
          PulseQuad.bl: PulseOscillator(1 - p.op, 1, p.bs * 0.84, p.bs * 0.55),
          PulseQuad.br: PulseOscillator(1 - p.op, 1, p.bs * 1.58, p.bs * 0.83),
        };

  final PulseParams _p;
  final List<PulseOscillator> _bw;
  final List<PulseOscillator> _bh;
  final List<PulseOscillator> _bx;
  final List<PulseOscillator> _by;
  final PulseOscillator _bgh;
  final Map<PulseQuad, PulseOscillator> _bop;
  final bool hueEnabled;

  PulseParams get params => _p;

  PulseValues sample(double t) {
    return PulseValues(
      bw: [for (final o in _bw) o.at(t)],
      bh: [for (final o in _bh) o.at(t)],
      bx: [for (final o in _bx) o.at(t)],
      by: [for (final o in _by) o.at(t)],
      bgh: _bgh.at(t),
      bop: {for (final e in _bop.entries) e.key: e.value.at(t)},
      // Continuous full-circle hue rotation, so the palette is never pinned
      // to fixed edges.
      hueDeg: hueEnabled ? (t / _p.huePeriod % 1) * 360 : 0,
    );
  }
}
