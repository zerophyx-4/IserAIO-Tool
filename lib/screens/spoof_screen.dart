import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/system_props.dart';

class SpoofScreen extends StatefulWidget {
  final HSRTheme theme;
  const SpoofScreen({super.key, required this.theme});

  @override
  State<SpoofScreen> createState() => _SpoofScreenState();
}

class _SpoofScreenState extends State<SpoofScreen> {
  final Map<String, bool> _enabled = {};
  final Map<String, String> _selectedDevice = {};
  final Map<String, String> _customProps = {
    'ro.product.manufacturer': '',
    'ro.product.brand': '',
    'ro.product.device': '',
    'ro.product.model': '',
    'ro.build.fingerprint': '',
    'ro.build.version.release': '',
  };
  String? _expanded;

  final _devices = ['Pixel 8 Pro', 'Samsung Galaxy S24 Ultra', 'OnePlus 12', 'Xiaomi 14 Pro', 'Sony Xperia 1 VI'];
  final _targets = [
    {'id': 'global',  'label': 'Global Device Spoof', 'icon': Icons.phone_android, 'color': 0xFF00C2FF, 'desc': 'Override build props globally'},
    {'id': 'netflix', 'label': 'Netflix Spoof',        'icon': Icons.movie,         'color': 0xFFFF4D4D, 'desc': 'Widevine L1 + certified device'},
    {'id': 'gphotos', 'label': 'Google Photos Spoof',  'icon': Icons.photo,         'color': 0xFF00E5A0, 'desc': 'Unlimited storage unlock'},
    {'id': 'custom',  'label': 'Custom Props',         'icon': Icons.edit,          'color': 0xFFA78BFA, 'desc': 'Manually edit build props'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spoofing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          ..._targets.map((t) {
            final id = t['id'] as String;
            final color = Color(t['color'] as int);
            final isExpanded = _expanded == id;
            final isEnabled = _enabled[id] ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _expanded = isExpanded ? null : id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isEnabled ? color.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.only(topLeft: const Radius.circular(14), topRight: const Radius.circular(14), bottomLeft: Radius.circular(isExpanded ? 0 : 14), bottomRight: Radius.circular(isExpanded ? 0 : 14)),
                        border: Border.all(color: isEnabled ? color.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.06)),
                        boxShadow: isEnabled ? [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 16)] : [],
                      ),
                      child: Row(
                        children: [
                          Icon(t['icon'] as IconData, color: color, size: 22),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(t['label'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xCCFFFFFF))),
                            Text(t['desc'] as String, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
                          ])),
                          GestureDetector(
                            onTap: () => setState(() => _enabled[id] = !isEnabled),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 42, height: 24,
                              decoration: BoxDecoration(color: isEnabled ? color : Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(99)),
                              child: AnimatedAlign(duration: const Duration(milliseconds: 250), curve: Curves.elasticOut, alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(margin: const EdgeInsets.all(2), width: 18, height: 18, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                              ),
                            ),
                          ),
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
                      child: id == 'custom' ? _customWidget(color) : _presetWidget(id, color),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _presetWidget(String id, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select device preset:', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3))),
        const SizedBox(height: 8),
        ..._devices.map((d) => GestureDetector(
          onTap: () => setState(() { _selectedDevice[id] = d; _enabled[id] = true; }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: _selectedDevice[id] == d ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(10), border: Border.all(color: _selectedDevice[id] == d ? color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06))),
            child: Text(d, style: TextStyle(fontSize: 12, color: _selectedDevice[id] == d ? color : Colors.white.withValues(alpha: 0.55), fontWeight: _selectedDevice[id] == d ? FontWeight.w600 : FontWeight.w400)),
          ),
        )),
      ],
    );
  }

  Widget _customWidget(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._customProps.keys.map((key) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(key, style: const TextStyle(fontSize: 10, color: Color(0xFFA78BFA), fontFamily: 'monospace')),
              const SizedBox(height: 4),
              TextField(
                style: const TextStyle(fontSize: 12, color: Colors.white),
                decoration: InputDecoration(
                  hintText: key.split('.').last,
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 12),
                  filled: true, fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: color)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onChanged: (v) => _customProps[key] = v,
              ),
            ],
          ),
        )),
        GestureDetector(
          onTap: () async { for (final e in _customProps.entries) { if (e.value.isNotEmpty) await SystemProps.set(e.key, e.value); } },
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.35))), child: Text('Apply Custom Props', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700))),
        ),
      ],
    );
  }
}