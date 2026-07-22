import 'package:border_beam_flutter/border_beam_flutter.dart';
import 'package:border_beam_flutter/src/pulse.dart';
import 'package:border_beam_flutter/src/types.dart' as t;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('builds every size variant without errors', (tester) async {
    for (final size in BorderBeamSize.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: BorderBeam(
              size: size,
              child: const SizedBox(width: 200, height: 100),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byType(BorderBeam), findsOneWidget);
    }
    // Let the last frame's ticker settle.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('fade-out fires onDeactivate', (tester) async {
    var deactivated = false;
    Widget build(bool active) => MaterialApp(
          home: BorderBeam(
            active: active,
            onDeactivate: () => deactivated = true,
            child: const SizedBox(width: 100, height: 50),
          ),
        );
    await tester.pumpWidget(build(true));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpWidget(build(false));
    await tester.pump(const Duration(milliseconds: 600));
    expect(deactivated, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('customColors builds and renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BorderBeam(
          customColors: const [Colors.teal, Colors.pink],
          child: const SizedBox(width: 200, height: 100),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(BorderBeam), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test('pulse oscillators ping-pong within their range', () {
    final bank = PulseOscillatorBank(
      pulseParams(t.BorderBeamSize.pulseInner, true, 2.3),
      hueEnabled: true,
    );
    for (var i = 0; i < 200; i++) {
      final v = bank.sample(i * 0.13);
      for (final w in v.bw) {
        expect(w, inInclusiveRange(1 - 0.28, 1 + 0.28 * 1.15 + 1e-9));
      }
      for (final op in v.bop.values) {
        expect(op, inInclusiveRange(1 - 0.48, 1.0 + 1e-9));
      }
      expect(v.hueDeg, inInclusiveRange(0, 360));
    }
  });
}
