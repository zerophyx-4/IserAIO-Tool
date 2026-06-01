import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isertoolkit/screens/home_screen.dart';
import 'package:isertoolkit/screens/tweaks_screen.dart';
import 'package:isertoolkit/screens/spoof_screen.dart';
import 'package:isertoolkit/screens/perapp_screen.dart';
import 'package:isertoolkit/screens/settings_screen.dart';
import 'package:isertoolkit/widgets/liquid_dock.dart';
import 'package:isertoolkit/utils/theme.dart';
import 'package:isertoolkit/utils/rom_detector.dart';
import 'package:isertoolkit/utils/device_detector.dart';
import 'package:isertoolkit/services/daemon_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([RomDetector.init(), DeviceDetector.init()]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const IserToolkitApp());
}

class IserToolkitApp extends StatelessWidget {
  const IserToolkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IserToolkit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(primary: Color(0xFF00C2FF)),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _activeTab = 'home';
  String _activeProfile = 'balanced';
  String _themeId = 'mountains';
  String? _restartDialog;
  String? _toast;

  final _tabs = const [
    DockTab(id: 'home',   icon: Icons.home_rounded,   label: 'Home'),
    DockTab(id: 'tweaks', icon: Icons.tune_rounded,    label: 'Tweaks'),
    DockTab(id: 'spoof',  icon: Icons.masks_rounded,   label: 'Spoof'),
    DockTab(id: 'perapp', icon: Icons.apps_rounded,    label: 'Per-app'),
  ];

  HSRTheme get _theme => AppTheme.themes[_themeId]!;

  void _showToast(String msg) {
    setState(() => _toast = msg);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  void _onRestartNeeded(String feature) {
    setState(() => _restartDialog = feature);
  }

  Future<void> _doRestart() async {
    setState(() => _restartDialog = null);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: _theme.bg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              IndexedStack(
                index: ['home', 'tweaks', 'spoof', 'perapp'].indexOf(_activeTab),
                children: [
                  HomeScreen(theme: _theme, activeProfile: _activeProfile, onProfileChanged: (p) => setState(() => _activeProfile = p)),
                  TweaksScreen(theme: _theme, onRestartNeeded: _onRestartNeeded),
                  SpoofScreen(theme: _theme),
                  PerAppScreen(theme: _theme),
                ],
              ),
              Positioned(
                top: 10, right: 16,
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: _theme.bg,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (_) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.85,
                      child: SettingsScreen(
                        currentThemeId: _themeId,
                        onThemeChanged: (id) {
                          setState(() => _themeId = id);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                      border: Border.all(color: _theme.accentBorder),
                    ),
                    child: Icon(Icons.settings_rounded, size: 14, color: _theme.accent),
                  ),
                ),
              ),
              Positioned(
                bottom: 22, left: 0, right: 0,
                child: Center(
                  child: LiquidDock(
                    tabs: _tabs,
                    activeTab: _activeTab,
                    theme: _theme,
                    onTabChanged: (id) => setState(() => _activeTab = id),
                  ),
                ),
              ),
              if (_restartDialog != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.65),
                    child: Center(
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A26),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Restart Required', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text('$_restartDialog needs a reboot to apply.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _restartDialog = null),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                      ),
                                      child: const Text('Later', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0x8CFFFFFF), fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _doRestart,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFF00C2FF), Color(0xFF0077BB)]),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [BoxShadow(color: const Color(0xFF00C2FF).withValues(alpha: 0.3), blurRadius: 16)],
                                      ),
                                      child: const Text('Restart Now', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (_toast != null)
                Positioned(
                  bottom: 90, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141420).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Text(_toast!, style: const TextStyle(fontSize: 12, color: Color(0xCCFFFFFF))),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}