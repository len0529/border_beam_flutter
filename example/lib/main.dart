import 'package:border_beam_flutter/border_beam_flutter.dart';
import 'package:flutter/material.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  bool dark = true;
  bool pulseTab = false;
  BorderBeamColorVariant variant = BorderBeamColorVariant.colorful;
  double strength = 1;
  bool active = true;

  @override
  Widget build(BuildContext context) {
    final theme = dark ? BorderBeamTheme.dark : BorderBeamTheme.light;
    final bg = dark ? const Color(0xFF000000) : const Color(0xFFF5F5F5);
    final cardBg = dark ? const Color(0xFF141414) : const Color(0xFFFFFFFF);
    final panelBg = dark ? const Color(0xFF0E0E0E) : const Color(0xFFEDEDED);
    final fg = dark ? Colors.white : Colors.black87;
    final subtle = dark ? Colors.white38 : Colors.black38;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: dark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: bg,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                children: [
                  Text('Border beam',
                      style: TextStyle(
                          color: fg,
                          fontSize: 28,
                          fontWeight: FontWeight.w600)),
                  Text('Animated border beam widget',
                      style: TextStyle(color: subtle, fontSize: 14)),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('Rotate')),
                          ButtonSegment(value: true, label: Text('Pulse')),
                        ],
                        selected: {pulseTab},
                        onSelectionChanged: (s) =>
                            setState(() => pulseTab = s.first),
                      ),
                      IconButton(
                        onPressed: () => setState(() => dark = !dark),
                        icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
                      ),
                      IconButton(
                        onPressed: () => setState(() => active = !active),
                        icon: Icon(active ? Icons.pause : Icons.play_arrow),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<BorderBeamColorVariant>(
                    segments: const [
                      ButtonSegment(
                          value: BorderBeamColorVariant.colorful,
                          label: Text('Colorful')),
                      ButtonSegment(
                          value: BorderBeamColorVariant.mono,
                          label: Text('Mono')),
                      ButtonSegment(
                          value: BorderBeamColorVariant.ocean,
                          label: Text('Ocean')),
                      ButtonSegment(
                          value: BorderBeamColorVariant.sunset,
                          label: Text('Sunset')),
                    ],
                    selected: {variant},
                    onSelectionChanged: (s) =>
                        setState(() => variant = s.first),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 72, horizontal: 20),
                    decoration: BoxDecoration(
                      color: panelBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: pulseTab
                        ? _pulseExamples(theme, cardBg, fg, subtle)
                        : _rotateExamples(theme, cardBg, fg, subtle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rotateExamples(
      BorderBeamTheme theme, Color cardBg, Color fg, Color subtle) {
    return Column(
      children: [
        // md — prompt input card
        BorderBeam(
          size: BorderBeamSize.md,
          colorVariant: variant,
          theme: theme,
          strength: strength,
          active: active,
          borderRadius: 16,
          child: _promptCard(cardBg, fg, subtle),
        ),
        const SizedBox(height: 48),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 32,
          runSpacing: 32,
          children: [
            // sm — icon button
            BorderBeam(
              size: BorderBeamSize.sm,
              colorVariant: variant,
              theme: theme,
              strength: strength,
              active: active,
              borderRadius: 22,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: subtle.withOpacity(0.2)),
                ),
                child: Icon(Icons.stop_rounded, color: subtle, size: 20),
              ),
            ),
            // line — search bar
            BorderBeam(
              size: BorderBeamSize.line,
              colorVariant: variant,
              theme: theme,
              strength: strength,
              active: active,
              borderRadius: 22,
              child: Container(
                width: 280,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: subtle.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18, color: subtle),
                    const SizedBox(width: 8),
                    Text('Search', style: TextStyle(color: subtle)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pulseExamples(
      BorderBeamTheme theme, Color cardBg, Color fg, Color subtle) {
    return Column(
      children: [
        // pulse-inner — working card
        BorderBeam(
          size: BorderBeamSize.pulseInner,
          colorVariant: variant,
          theme: theme,
          strength: strength,
          active: active,
          borderRadius: 16,
          child: Container(
            width: 290,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Working…', style: TextStyle(color: subtle)),
                const SizedBox(height: 16),
                for (final task in const [
                  'Generate color palettes',
                  'Recommend font pairings',
                  'Create layout templates',
                  'Build section engine',
                ]) ...[
                  Row(children: [
                    Icon(Icons.circle_outlined, size: 16, color: subtle),
                    const SizedBox(width: 10),
                    Text(task, style: TextStyle(color: fg, fontSize: 14)),
                  ]),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 64),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 64,
          runSpacing: 64,
          children: [
            // pulse-outside — subscribe button
            BorderBeam(
              size: BorderBeamSize.pulseOutside,
              colorVariant: variant,
              theme: theme,
              strength: strength,
              active: active,
              borderRadius: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: subtle.withOpacity(0.3)),
                ),
                child: Text('Subscribe',
                    style:
                        TextStyle(color: fg, fontWeight: FontWeight.w600)),
              ),
            ),
            // pulse-outside — prompt input
            BorderBeam(
              size: BorderBeamSize.pulseOutside,
              colorVariant: variant,
              theme: theme,
              strength: strength,
              active: active,
              borderRadius: 16,
              child: _promptCard(cardBg, fg, subtle, width: 300, height: 120),
            ),
          ],
        ),
      ],
    );
  }

  Widget _promptCard(Color cardBg, Color fg, Color subtle,
      {double width = 340, double height = 118}) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subtle.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.alternate_email, size: 16, color: subtle),
          const Spacer(),
          Text('Build anything…', style: TextStyle(color: subtle)),
          const Spacer(),
          Row(
            children: [
              _chip('Agent', subtle),
              const SizedBox(width: 6),
              _chip('Auto', subtle),
              const Spacer(),
              Icon(Icons.arrow_upward, size: 16, color: subtle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color subtle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: subtle.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: subtle, fontSize: 12)),
    );
  }
}
