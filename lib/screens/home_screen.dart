import 'package:flutter/material.dart';
import '../widgets/banner_widget.dart';
import '../widgets/profile_selector.dart';
import '../widgets/stat_bar.dart';
import '../widgets/toggle_card.dart';
import '../utils/theme.dart';
import '../services/daemon_client.dart';

class HomeScreen extends StatefulWidget {
  final HSRTheme theme;
  final String activeProfile;
  final ValueChanged<String> onProfileChanged;
  const HomeScreen({super.key, required this.theme, required this.activeProfile, required this.onProfileChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _blur = true;
  bool _adBlock = false;
  String _flashMode = '';
  double _cpu = 23, _gpu = 11, _ram = 3.2, _bat = 78;
  double _cpuTemp = 38, _gpuTemp = 35, _batTemp = 31;

  @override
  void initState() {
    super.initState();
    _startStats();
  }

  void _startStats() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      setState(() {
        _cpu = (_cpu + ((_cpu < 50) ? 3 : -3)).clamp(5.0, 95.0);
        _gpu = (_gpu + 2 - 4 * 0.5).clamp(2.0, 80.0);
        _cpuTemp = (_cpuTemp + 0.5 - 1 * 0.5).clamp(32.0, 55.0);
        _gpuTemp = (_gpuTemp + 0.4 - 0.8 * 0.5).clamp(30.0, 52.0);
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BannerWidget(theme: widget.theme, deviceName: 'cannon · MediaTek Helio G85', romName: 'HyperOS Port', androidVer: '14', kernelVer: '5.15.104-hsr'),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: widget.theme.accentBorder),
                  ),
                  child: Column(
                    children: [
                      _statRow('CPU', _cpu, 100, '${_cpu.round()}% · ${_cpuTemp.round()}C', const Color(0xFFFF8C00)),
                      const SizedBox(height: 10),
                      _statRow('GPU', _gpu, 100, '${_gpu.round()}% · ${_gpuTemp.round()}C', widget.theme.accent),
                      const SizedBox(height: 10),
                      _statRow('RAM', _ram, 6, '${_ram.toStringAsFixed(1)}/6GB', const Color(0xFFA78BFA)),
                      const SizedBox(height: 10),
                      _statRow('BAT', _bat, 100, '${_bat.round()}% · ${_batTemp.round()}C', const Color(0xFF00E5A0)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ProfileSelector(activeProfile: widget.activeProfile, onChanged: (p) async { widget.onProfileChanged(p); await DaemonClient.setProfile(p); }),
                const SizedBox(height: 14),
                Text('Quick Toggles', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.5))),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _flashMode.isNotEmpty ? const Color(0xFFFFD700).withOpacity(0.08) : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _flashMode.isNotEmpty ? const Color(0xFFFFD700).withOpacity(0.35) : Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Text('Flashlight', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text('Flashlight', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8))),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        _flashBtn('front', 'Front Only'),
                        const SizedBox(width: 6),
                        _flashBtn('both', 'Front + Back'),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ToggleCard(label: 'Blur Effects', sub: 'System-wide blur toggle', value: _blur, color: widget.theme.accent, onChanged: (v) => setState(() => _blur = v)),
                const SizedBox(height: 8),
                ToggleCard(label: 'Ad Block', sub: 'DNS-based ad blocking', value: _adBlock, color: const Color(0xFF00E5A0), onChanged: (v) => setState(() => _adBlock = v)),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, double value, double max, String unit, Color color) {
    return Row(
      children: [
        SizedBox(width: 30, child: Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.35), letterSpacing: 1))),
        Expanded(child: StatBar(value: value, max: max, color: color)),
        const SizedBox(width: 8),
        Text(unit, style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }

  Widget _flashBtn(String mode, String label) {
    final isActive = _flashMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() => _flashMode = isActive ? '' : mode);
          await DaemonClient.setFrontFlash(_flashMode.isNotEmpty);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFD700).withOpacity(0.18) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? const Color(0xFFFFD700).withOpacity(0.45) : Colors.white.withOpacity(0.08)),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isActive ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.4), fontWeight: isActive ? FontWeight.w700 : FontWeight.w400)),
        ),
      ),
    );
  }
}