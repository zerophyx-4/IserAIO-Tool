import 'package:flutter/material.dart';
import '../widgets/toggle_card.dart';
import '../utils/theme.dart';
import '../utils/rom_detector.dart';
import '../services/daemon_client.dart';
import '../services/system_props.dart';

class TweaksScreen extends StatefulWidget {
  final HSRTheme theme;
  final ValueChanged<String> onRestartNeeded;
  const TweaksScreen({super.key, required this.theme, required this.onRestartNeeded});

  @override
  State<TweaksScreen> createState() => _TweaksScreenState();
}

class _TweaksScreenState extends State<TweaksScreen> {
  final Map<String, bool> _tweaks = {};
  int _hyperV = 2, _hyperC = 2, _hyperG = 2;
  int _oplusLevel = 3;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Tweaks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          ...[
            {'id': 'thermal',      'label': 'Thermal Control',      'sub': 'Disable thermal throttling',  'color': 0xFFFF4D4D, 'restart': true},
            {'id': 'rotation_btn', 'label': 'Hide Rotation Button', 'sub': 'Remove corner rotation btn',  'color': 0xFF00E5A0, 'restart': false},
            {'id': 'blur',         'label': 'Blur Effects',         'sub': 'System-wide blur toggle',     'color': 0xFF00C2FF, 'restart': false},
            {'id': 'angle',        'label': 'ANGLE Renderer',       'sub': 'Force ANGLE GPU renderer',    'color': 0xFFFF8C00, 'restart': true},
            {'id': 'skia',         'label': 'SKIA Vulkan',          'sub': 'Force SKIA Vulkan renderer',  'color': 0xFF67E8F9, 'restart': true},
            {'id': 'adblock',      'label': 'Ad Block',             'sub': 'DNS-based ad blocking',       'color': 0xFF00E5A0, 'restart': false},
            {'id': 'selinux',      'label': 'SELinux Permissive',   'sub': 'Dev mode only',               'color': 0xFFA78BFA, 'restart': true, 'dev': true},
          ].map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ToggleCard(
              label: t['label'] as String,
              sub: t['sub'] as String,
              value: _tweaks[t['id']] ?? false,
              color: Color(t['color'] as int),
              needsRestart: t['restart'] as bool,
              devOnly: (t['dev'] as bool?) ?? false,
              onChanged: (v) {
                setState(() => _tweaks[t['id'] as String] = v);
                if ((t['restart'] as bool) && v) widget.onRestartNeeded(t['label'] as String);
              },
            ),
          )),
          if (RomDetector.isHyperos) ...[
            const SizedBox(height: 16),
            _sectionHeader('HyperOS Exclusive', const Color(0xFFFF8C00)),
            const SizedBox(height: 8),
            _hyperAnimCard(),
            const SizedBox(height: 8),
            ToggleCard(label: 'Rounded Corner', sub: 'Smooth corner view & window', value: _tweaks['rounded'] ?? false, color: const Color(0xFF00C2FF), onChanged: (v) async { setState(() => _tweaks['rounded'] = v); await SystemProps.set('persist.sys.support_view_smoothcorner', v ? 'true' : 'false'); await SystemProps.set('persist.sys.support_window_smoothcorner', v ? 'true' : 'false'); }),
            const SizedBox(height: 8),
            ToggleCard(label: 'Blur App Launch', sub: 'Blur on app launch', value: _tweaks['blur_launch'] ?? false, color: const Color(0xFF00C2FF), needsRestart: true, onChanged: (v) async { setState(() => _tweaks['blur_launch'] = v); await SystemProps.set('ro.launcher.blur.appLaunch', v ? '1' : '0'); }),
            if (RomDetector.isHyperos3) ...[
              const SizedBox(height: 8),
              ToggleCard(label: 'Glass Effect', sub: 'HyperOS 3+ glass visual', value: _tweaks['glass'] ?? false, color: const Color(0xFF67E8F9), onChanged: (v) async { setState(() => _tweaks['glass'] = v); await SystemProps.set('persist.sys.advanced_visual_release', v ? '4' : '0'); }),
            ],
          ],
          if (RomDetector.isOplus) ...[
            const SizedBox(height: 16),
            _sectionHeader('Oplus Exclusive', const Color(0xFF00E5A0)),
            const SizedBox(height: 8),
            _oplusAnimCard(),
          ],
          if (RomDetector.isTranos) ...[
            const SizedBox(height: 16),
            _sectionHeader('TranOS Exclusive', const Color(0xFF67E8F9)),
            const SizedBox(height: 8),
            if (RomDetector.isTranos15) ...[
              ToggleCard(label: 'Dockbar', sub: 'Enable hotseat dockbar', value: _tweaks['dockbar'] ?? false, color: const Color(0xFF67E8F9), needsRestart: true, onChanged: (v) async { setState(() => _tweaks['dockbar'] = v); await SystemProps.set('ro.os.tran_hotseat_background', v ? '1' : '0'); }),
              const SizedBox(height: 8),
            ],
            if (RomDetector.isTranos15Plus) ...[
              ToggleCard(label: 'Always Show Dynamic Bar', sub: 'Always show dynamic status bar', value: _tweaks['dynbar'] ?? false, color: const Color(0xFF67E8F9), needsRestart: true, onChanged: (v) async { setState(() => _tweaks['dynbar'] = v); await SystemProps.set('ro.tran.sw.special_status_bar_icons_space', v ? '1' : '0'); await SystemProps.set('ro.os_dynamic_bar_resident_plane_support', v ? '1' : '0'); }),
              const SizedBox(height: 8),
            ],
            ToggleCard(label: 'Blur Recent Apps', sub: 'Blur in recent apps', value: _tweaks['blur_recent'] ?? false, color: const Color(0xFF67E8F9), needsRestart: true, onChanged: (v) async { setState(() => _tweaks['blur_recent'] = v); await SystemProps.set('ro.os.recent.blur', v ? '1' : '0'); }),
            const SizedBox(height: 8),
            ToggleCard(label: 'Hide Freezer', sub: 'Hide freezer from UI', value: _tweaks['hide_freezer'] ?? false, color: const Color(0xFF67E8F9), needsRestart: true, onChanged: (v) async { setState(() => _tweaks['hide_freezer'] = v); await SystemProps.set('ro.tran.hide.freezer', v ? '1' : '0'); }),
            const SizedBox(height: 8),
            ToggleCard(label: 'Disable Anti-Crack', sub: 'Enable for spoofing to work', value: _tweaks['anti_crack'] ?? false, color: const Color(0xFFFF4D4D), needsRestart: true, onChanged: (v) async { setState(() => _tweaks['anti_crack'] = v); await SystemProps.set('ro.vendor.tran.anti.crack.p7.support', v ? '0' : '1'); }),
          ],
          if (RomDetector.isAosp) ...[
            const SizedBox(height: 16),
            _sectionHeader('AOSP Exclusive', const Color(0xFFA78BFA)),
            const SizedBox(height: 8),
            ...[
              {'id': 'sf_blur',    'prop': 'ro.surface_flinger.supports_background_blur', 'label': 'SF Background Blur'},
              {'id': 'sf_disable', 'prop': 'persist.sys.sf.disable_blurs',                'label': 'Disable SF Blurs'},
              {'id': 'sf_media',   'prop': 'ro.surface_flinger.media_panel_bg_blur',      'label': 'Media Panel Blur'},
              {'id': 'win_blur',   'prop': 'disable_window_blurs',                        'label': 'Disable Window Blurs'},
              {'id': 'blur_caro',  'prop': 'ro.sf.blurs_are_caro',                        'label': 'Blurs Are Caro'},
              {'id': 'blur_exp',   'prop': 'ro.sf.blurs_are_expensive',                   'label': 'Blurs Are Expensive'},
            ].map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ToggleCard(label: t['label']!, sub: t['prop']!, value: _tweaks[t['id']] ?? false, color: const Color(0xFFA78BFA), needsRestart: true, onChanged: (v) async { setState(() => _tweaks[t['id']!] = v); await SystemProps.set(t['prop']!, v ? '1' : '0'); widget.onRestartNeeded(t['label']!); }),
            )),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Row(children: [
      Container(width: 3, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99))),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ]);
  }

  Widget _hyperAnimCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Animation Level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.85))),
          const SizedBox(height: 12),
          _sliderRow('V', _hyperV, (v) => setState(() => _hyperV = v)),
          _sliderRow('C', _hyperC, (v) => setState(() => _hyperC = v)),
          _sliderRow('G', _hyperG, (v) => setState(() => _hyperG = v)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async { await DaemonClient.sendCommand('SET_ANIM_HYPER', 'v:$_hyperV,c:$_hyperC,g:$_hyperG'); },
            child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: const Color(0xFFFF8C00).withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.35))), child: const Text('Apply', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFFFF8C00), fontWeight: FontWeight.w700))),
          ),
        ],
      ),
    );
  }

  Widget _oplusAnimCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Animation Level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.85))),
          const SizedBox(height: 12),
          _sliderRow('Level', _oplusLevel, (v) async { setState(() => _oplusLevel = v); await SystemProps.set('persist.sys.oplus.anim_level', v.toString()); }, max: 5),
        ],
      ),
    );
  }

  Widget _sliderRow(String label, int value, ValueChanged<int> onChanged, {int max = 3}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)))),
          Expanded(
            child: SliderTheme(
              data: const SliderThemeData(trackHeight: 3, thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7)),
              child: Slider(value: value.toDouble(), min: 1, max: max.toDouble(), divisions: max - 1, activeColor: widget.theme.accent, inactiveColor: Colors.white10, onChanged: (v) => onChanged(v.round())),
            ),
          ),
          SizedBox(width: 24, child: Text('$value', style: TextStyle(fontSize: 12, color: widget.theme.accent, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}