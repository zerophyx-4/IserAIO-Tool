import 'package:flutter/material.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  final String currentThemeId;
  final ValueChanged<String> onThemeChanged;
  const SettingsScreen({super.key, required this.currentThemeId, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _tab = 'theme';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle), child: const Icon(Icons.close, size: 16, color: Colors.white54))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: ['theme', 'about'].map((t) {
              final isActive = _tab == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = t),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF00C2FF).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isActive ? const Color(0xFF00C2FF).withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Text(t[0].toUpperCase() + t.substring(1), textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isActive ? const Color(0xFF00C2FF) : Colors.white.withValues(alpha: 0.4), fontWeight: isActive ? FontWeight.w700 : FontWeight.w400)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _tab == 'theme' ? _themeTab() : _aboutTab(),
          ),
        ),
      ],
    );
  }

  Widget _themeTab() {
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.4,
      children: AppTheme.themes.entries.map((entry) {
        final id = entry.key;
        final th = entry.value;
        final isSelected = widget.currentThemeId == id;
        return GestureDetector(
          onTap: () => widget.onThemeChanged(id),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? th.accent : Colors.transparent, width: 2), boxShadow: isSelected ? [BoxShadow(color: th.accent.withValues(alpha: 0.4), blurRadius: 16)] : []),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [th.bannerStart, th.bannerEnd])),
                      child: Stack(children: [
                        if (isSelected) Positioned(top: 6, right: 6, child: Container(width: 18, height: 18, decoration: BoxDecoration(color: th.accent, shape: BoxShape.circle), child: const Icon(Icons.check, size: 12, color: Colors.black))),
                        Positioned(bottom: 6, left: 8, child: Text(th.label, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600))),
                      ]),
                    ),
                  ),
                  Container(
                    color: th.bg, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(children: [th.accent, th.accentSoft, Colors.white.withValues(alpha: 0.2)].map((c) => Container(margin: const EdgeInsets.only(right: 4), width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle))).toList()),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _aboutTab() {
    return Column(
      children: [
        _aboutSection('About Toolkit', [['Name', 'IserToolkit'], ['Version', 'V1.0'], ['Author', 'haiser']]),
        const SizedBox(height: 10),
        _aboutSection('About ROM', [['ROM Name', 'HyperOS Port'], ['Android', '14'], ['OS Version', '2']]),
        const SizedBox(height: 10),
        _aboutSection('About Device', [['Device', 'cannon'], ['Chipset', 'MediaTek Helio G85'], ['Kernel', '5.15.104-hsr'], ['RAM', '6GB']]),
      ],
    );
  }

  Widget _aboutSection(String title, List<List<String>> items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)))), child: Row(children: [Text(title.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.w600, letterSpacing: 1))])),
          ...items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.03)))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(item[0], style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
              Text(item[1], style: const TextStyle(fontSize: 12, color: Color(0xBFFFFFFF), fontWeight: FontWeight.w600)),
            ]),
          )),
        ],
      ),
    );
  }
}