import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'config.dart';
import 'filters.dart';
import 'line_painter.dart';
import 'paint_utils.dart';
import 'presets.dart';
import 'pulse.dart';
import 'pulse_painters.dart';
import 'rotate_painter.dart';
import 'types.dart';

/// BorderBeam — animated border beam effect for Flutter.
///
/// Wraps [child] and overlays a traveling or breathing glow animation.
/// Port of the `border-beam` React package.
///
/// ```dart
/// BorderBeam(
///   child: Card(child: Text('Content')),
/// )
/// ```
class BorderBeam extends StatefulWidget {
  const BorderBeam({
    super.key,
    required this.child,
    this.size = BorderBeamSize.md,
    this.colorVariant = BorderBeamColorVariant.colorful,
    this.customColors,
    this.theme = BorderBeamTheme.dark,
    this.staticColors = false,
    this.duration,
    this.active = true,
    this.borderRadius,
    this.brightness,
    this.saturation,
    this.hueRange = 30,
    this.strength = 1,
    this.onActivate,
    this.onDeactivate,
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

  /// Content to wrap with the border beam effect.
  final Widget child;

  /// Size/type preset. Defaults to [BorderBeamSize.md].
  final BorderBeamSize size;

  /// Color palette. Defaults to [BorderBeamColorVariant.colorful].
  final BorderBeamColorVariant colorVariant;

  /// Custom colors for the beam. When provided (non-empty), they override
  /// [colorVariant]: the colors are distributed cyclically over the gradient
  /// slots of the effect, so any number of colors (one or more) works.
  /// Custom colors are rendered as supplied — the hue-shift animation of the
  /// built-in palettes is disabled.
  final List<Color>? customColors;

  /// Theme mode — adapts beam/glow colors for dark or light backgrounds.
  /// [BorderBeamTheme.auto] follows the platform brightness.
  final BorderBeamTheme theme;

  /// Disable the hue-shift animation for static colors. Forced on for the
  /// mono variant.
  final bool staticColors;

  /// Rotation/travel/breathe cycle duration in seconds.
  /// Defaults: 1.96 (rotate) / 3.1 (line) / 2.3 (pulse).
  final double? duration;

  /// Whether the animation is active (fades in/out on change).
  final bool active;

  /// Border radius in logical px. Unlike the web version there is no DOM to
  /// inspect, so pass the wrapped element's radius here; falls back to the
  /// size preset default (16, or 32 for `sm`).
  final double? borderRadius;

  /// Brightness multiplier for the glow. Falls back to the type preset.
  final double? brightness;

  /// Saturation multiplier for the glow. Falls back to the theme preset.
  final double? saturation;

  /// Hue rotation range in degrees for the rotate/line hue-shift animation.
  final double hueRange;

  /// Overall strength/opacity of the effect (0–1). Only affects the beam
  /// layers, never [child].
  final double strength;

  /// Called when the fade-in completes.
  final VoidCallback? onActivate;

  /// Called when the fade-out completes.
  final VoidCallback? onDeactivate;

  /// Consumer hooks (parity with the CSS custom-property tuning hooks):
  /// extra multipliers on the stroke/inner/bloom layer opacities.
  final double strokeOpacityFactor;
  final double innerOpacityFactor;
  final double bloomOpacityFactor;

  /// Relative multiplier on the measured pulse glow scale
  /// (`--pulse-glow-boost`).
  final double glowBoost;

  /// Overrides for the pulse-outside glow blurs (`--beam-core-blur` /
  /// `--beam-bloom-blur`), in logical px (Gaussian σ).
  final double? coreBlur;
  final double? bloomBlur;

  /// Overrides for the pulse-outside glow brightness/saturation
  /// (`--beam-glow-brightness` / `--beam-glow-saturate`).
  final double? glowBrightness;
  final double? glowSaturation;

  /// Base hue offset in degrees (`--beam-hue-base`).
  final double hueBase;

  @override
  State<BorderBeam> createState() => _BorderBeamState();
}

class _BorderBeamState extends State<BorderBeam>
    with TickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<double> _time = ValueNotifier(0);
  late final AnimationController _fadeController;
  late final Animation<double> _fade;

  PulseOscillatorBank? _bank;
  int _bankKey = 0;
  BeamPalettes? _palettes;
  BorderBeamColorVariant? _palettesVariant;
  List<Color>? _palettesCustom;

  bool get _isPulse =>
      widget.size == BorderBeamSize.pulseInner ||
      widget.size == BorderBeamSize.pulseOutside;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.ease);
    _fadeController.addStatusListener(_onFadeStatus);
    _ticker = createTicker(_onTick);
    if (widget.active) {
      _fadeController.forward();
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6;
    if (_isPulse) {
      // ~30fps cap — the breathing is slow, so halving the paint frequency
      // is imperceptible (same throttle as the web pulse driver).
      if (t - _time.value >= 1 / 30 - 0.002) _time.value = t;
    } else {
      _time.value = t;
    }
  }

  void _onFadeStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onActivate?.call();
    } else if (status == AnimationStatus.dismissed) {
      widget.onDeactivate?.call();
      if (_ticker.isActive) _ticker.stop();
    }
  }

  @override
  void didUpdateWidget(BorderBeam oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        if (!_ticker.isActive) _ticker.start();
        _fadeController.forward();
      } else {
        _fadeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _fadeController.dispose();
    _time.dispose();
    super.dispose();
  }

  BeamPalettes _obtainPalettes() {
    final custom = widget.customColors;
    if (_palettes == null ||
        _palettesVariant != widget.colorVariant ||
        !listEquals(_palettesCustom, custom)) {
      _palettes = resolvePalettes(widget.colorVariant, custom);
      _palettesVariant = widget.colorVariant;
      _palettesCustom = custom == null ? null : List.of(custom);
    }
    return _palettes!;
  }

  PulseOscillatorBank _obtainBank(
      BorderBeamSize size, bool isDark, double duration, bool staticColors) {
    final key = Object.hash(size, isDark, duration, staticColors);
    if (_bank == null || _bankKey != key) {
      _bank = PulseOscillatorBank(
        pulseParams(size, isDark, duration),
        hueEnabled: !staticColors,
      );
      _bankKey = key;
    }
    return _bank!;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final isPulse = _isPulse;
    final isLine = size == BorderBeamSize.line;

    final isDark = switch (widget.theme) {
      BorderBeamTheme.dark => true,
      BorderBeamTheme.light => false,
      BorderBeamTheme.auto =>
        (MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.dark) ==
            Brightness.dark,
    };
    final themeMode = isDark ? BorderBeamTheme.dark : BorderBeamTheme.light;
    final tc = sizeThemePresets[size]![themeMode]!;
    final sc = sizePresets[size]!;

    final hasCustomColors =
        widget.customColors != null && widget.customColors!.isNotEmpty;
    final staticColors = widget.colorVariant == BorderBeamColorVariant.mono ||
        hasCustomColors ||
        widget.staticColors;
    final duration =
        widget.duration ?? (isLine ? 3.1 : (isPulse ? 2.3 : 1.96));

    final config = BeamConfig(
      size: size,
      palettes: _obtainPalettes(),
      colorVariant: widget.colorVariant,
      isDark: isDark,
      borderRadius: widget.borderRadius ?? sc.borderRadius,
      borderWidth: sc.borderWidth,
      duration: duration,
      strokeOpacity: tc.strokeOpacity,
      innerOpacity: tc.innerOpacity,
      bloomOpacity: tc.bloomOpacity,
      innerShadow: tc.innerShadow,
      brightness: widget.brightness ?? tc.brightness ?? 1.3,
      saturation: widget.saturation ?? tc.saturation,
      hueRange: isLine ? math.min(widget.hueRange, 13) : widget.hueRange,
      staticColors: staticColors,
      strength: widget.strength.clamp(0.0, 1.0),
      hairlineOpacity: tc.hairlineOpacity ?? 0,
      strokeOpacityFactor: widget.strokeOpacityFactor,
      innerOpacityFactor: widget.innerOpacityFactor,
      bloomOpacityFactor: widget.bloomOpacityFactor,
      glowBoost: widget.glowBoost,
      coreBlur: widget.coreBlur,
      bloomBlur: widget.bloomBlur,
      glowBrightness: widget.glowBrightness,
      glowSaturation: widget.glowSaturation,
      hueBase: widget.hueBase,
    );

    // Web parity: the pulse types ship a prefers-reduced-motion block that
    // disables their animations entirely (the effect stays invisible).
    final reducedMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (isPulse && reducedMotion) return widget.child;

    final child = RepaintBoundary(child: widget.child);

    switch (size) {
      case BorderBeamSize.sm:
      case BorderBeamSize.md:
        return Stack(
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: RotateBeamPainter(
                        config: config, time: _time, fade: _fade),
                  ),
                ),
              ),
            ),
          ],
        );

      case BorderBeamSize.line:
        return Stack(
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: LineBeamPainter(
                        config: config, time: _time, fade: _fade),
                  ),
                ),
              ),
            ),
          ],
        );

      case BorderBeamSize.pulseInner:
        final bank = _obtainBank(size, isDark, duration, staticColors);
        return Stack(
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: PulseInnerPainter(
                        config: config, bank: bank, time: _time, fade: _fade),
                  ),
                ),
              ),
            ),
            // z3: frozen bloom, blurred + hue-rotated at composite time.
            Positioned.fill(
              child: IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, constraints) => ClipRRect(
                    borderRadius: BorderRadius.circular(clampRadius(
                        config.borderRadius, constraints.biggest)),
                    child: _FilteredBloom(
                    config: config,
                    bank: bank,
                    time: _time,
                    fade: _fade,
                    blurSigma: 8,
                    brightness: config.brightness,
                    saturation: config.saturation,
                      painter: PulseInnerBloomPainter(
                        config: config,
                        frozenAlpha: frozenBloomAlpha(size, isDark, duration),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case BorderBeamSize.pulseOutside:
        final bank = _obtainBank(size, isDark, duration, staticColors);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Behind the (opaque) child: wide frozen halo, then the core glow.
            Positioned.fill(
              child: IgnorePointer(
                child: _FilteredBloom(
                  config: config,
                  bank: bank,
                  time: _time,
                  fade: _fade,
                  blurSigma: config.bloomBlur ?? (isDark ? 22.5 : 15),
                  brightness: config.glowBrightness ?? config.brightness,
                  saturation: config.glowSaturation ?? config.saturation,
                  opacityBase: (config.bloomOpacity *
                          config.monoMul *
                          config.bloomOpacityFactor *
                          config.strength)
                      .clamp(0.0, 1.0),
                  painter: PulseOuterBloomPainter(
                    config: config,
                    frozenAlpha: frozenBloomAlpha(size, isDark, duration),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: PulseOuterCorePainter(
                        config: config, bank: bank, time: _time, fade: _fade),
                  ),
                ),
              ),
            ),
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: PulseOuterStrokePainter(
                        config: config, bank: bank, time: _time, fade: _fade),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}

/// Frozen bloom subtree: a cached raster ([RepaintBoundary]) with blur and the
/// animated hue-rotate applied at composite time — the Flutter equivalent of
/// the web version's "paint the blurred bitmap once, only vary the cheap
/// hue-rotate filter" optimization.
class _FilteredBloom extends StatelessWidget {
  const _FilteredBloom({
    required this.config,
    required this.bank,
    required this.time,
    required this.fade,
    required this.blurSigma,
    required this.brightness,
    required this.saturation,
    required this.painter,
    this.opacityBase,
  });

  final BeamConfig config;
  final PulseOscillatorBank bank;
  final ValueListenable<double> time;
  final Animation<double> fade;
  final double blurSigma;
  final double brightness;
  final double saturation;
  final CustomPainter painter;

  /// Bloom layer opacity excluding the fade; defaults to the config's bloom
  /// opacity product.
  final double? opacityBase;

  @override
  Widget build(BuildContext context) {
    final base = opacityBase ??
        (config.bloomOpacity *
                config.monoMul *
                config.bloomOpacityFactor *
                config.strength)
            .clamp(0.0, 1.0);

    Widget content = RepaintBoundary(
      child: CustomPaint(painter: painter, child: const SizedBox.expand()),
    );
    content = ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
          sigmaX: blurSigma, sigmaY: blurSigma, tileMode: TileMode.decal),
      child: content,
    );

    if (config.staticColors) {
      content = ColorFiltered(
        colorFilter: beamColorFilter(
            hueDegrees: 0, brightness: brightness, saturation: saturation),
        child: content,
      );
    } else {
      content = AnimatedBuilder(
        animation: time,
        builder: (context, child) => ColorFiltered(
          colorFilter: beamColorFilter(
            hueDegrees: config.hueBase + bank.sample(time.value).hueDeg,
            brightness: brightness,
            saturation: saturation,
          ),
          child: child,
        ),
        child: content,
      );
    }

    return FadeTransition(
      opacity: fade.drive(Tween(begin: 0.0, end: base)),
      child: content,
    );
  }
}
