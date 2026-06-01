import 'package:flutter/material.dart';
import '../utils/theme.dart';

class PerAppScreen extends StatefulWidget {
  final HSRTheme theme;
  const PerAppScreen({super.key, required this.theme});

  @override
  State<PerAppScreen> createState() => _PerAppScreenState();
}

class _PerAppScreenState extends State<PerAppScreen> {
  final _apps = [
    {'pkg': 'com.instagram.android', 'name': 'Instagram',      'icon': Icons.camera_alt},
    {'pkg': 'com.snapchat.android',  'name': 'Snapchat',       'icon': Icons.emoji_emotions},
    {'pkg': 'com.whatsapp',          'name': 'WhatsApp',       'icon': Icons.message},
    {'pkg': 'com.spotify.music',     'name': 'Spotify',        'icon': Icons.music_note},
    {'pkg': 'com.pubg.mobile',       'name': 'PUBG Mobile',    'icon': Icons.sports_esports},
    {'pkg': 'com.mobile.legends',    'name': 'Mobile Legends', 'icon': Icons.shield},
  ];
  final Map<String, Map<String, bool>> _perApp = {};
  String? _expanded;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Per-app Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          ..._apps.map((app) {
            final pkg = app['pkg'] as String;
            final isExpanded = _expanded == pkg;
            final hasCustom = _perApp[pkg]?.values.any((v) => v) ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _expanded = isExpanded ? null : pkg),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.only(topLeft: const Radius.circular(14), topRight: const Radius.circular(14), bottomLeft: Radius.circular(isExpanded ? 0 : 14), bottomRight: Radius.circular(isExpanded ? 0 : 14)),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Row(
                        children: [
                          Icon(app['icon'] as IconData, color: widget.theme.accent, size: 22),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(app['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xCCFFFFFF))),
                            Text(pkg, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.25), fontFamily: 'monospace')),
                          ])),
                          if (hasCustom) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF00C2FF).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(99)), child: const Text('CUSTOM', style: TextStyle(fontSize: 9, color: Color(0xFF00C2FF), fontWeight: FontWeight.w700))),
                          const SizedBox(width: 8),
                          AnimatedRotation(turns: isExpanded ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.3), size: 18)),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)), border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
                      child: Column(
                        children: [
                          {'key': 'spoof',       'label': 'Device Spoof',       'color': 0xFF00C2FF},
                          {'key': 'flag_secure', 'label': 'Disable FLAG_SECURE', 'color': 0xFFFF8C00},
                          {'key': 'perf_mode',   'label': 'Force Gaming Mode',   'color': 0xFFFF4D4D},
                          {'key': 'no_blur',     'label': 'Disable Blur',        'color': 0xFFA78BFA},
                        ].map((opt) {
                          final key = opt['key'] as String;
                          final color = Color(opt['color'] as int);
                          final isOn = _perApp[pkg]?[key] ?? false;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(opt['label'] as String, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
                                GestureDetector(
                                  onTap: () => setState(() { _perApp[pkg] ??= {}; _perApp[pkg]![key] = !isOn; }),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: 42, height: 24,
                                    decoration: BoxDecoration(color: isOn ? color : Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(99)),
                                    child: AnimatedAlign(duration: const Duration(milliseconds: 250), curve: Curves.elasticOut, alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(margin: const EdgeInsets.all(2), width: 18, height: 18, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}