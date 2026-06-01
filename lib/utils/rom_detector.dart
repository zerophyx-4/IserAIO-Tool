import '../services/system_props.dart';

class RomDetector {
  static String _romName = '';
  static int _androidVer = 0;
  static int _osVersion = 0;

  static Future<void> init() async {
    try {
      _romName = await SystemProps.get('ro.aiotool.hsr.rom_name', '');
      _androidVer = int.tryParse(await SystemProps.get('ro.aiotool.hsr.android_ver', '0')) ?? 0;
      _osVersion = int.tryParse(await SystemProps.get('ro.aiotool.hsr.os_version', '0')) ?? 0;
    } catch (_) {}
  }

  static String get romName => _romName;
  static int get androidVer => _androidVer;
  static int get osVersion => _osVersion;
  static bool get isHyperos => _romName == 'hyperos';
  static bool get isOplus => ['coloros', 'realmeos', 'oxygenos'].contains(_romName);
  static bool get isTranos => ['xos', 'hios', 'itelos'].contains(_romName);
  static bool get isAosp => _romName == 'aosp';
  static bool get isHyperos3 => isHyperos && _osVersion >= 3;
  static bool get isTranos15 => isTranos && _osVersion == 15;
  static bool get isTranos15Plus => isTranos && _osVersion >= 15;
  static bool get isTranos16Plus => isTranos && _osVersion >= 16;
}