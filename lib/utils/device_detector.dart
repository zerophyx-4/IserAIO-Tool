import '../services/system_props.dart';

class DeviceDetector {
  static String _deviceName = '';
  static String _chipset = '';
  static String _manufacturer = '';
  static String _brand = '';
  static String _model = '';
  static String _androidVer = '';
  static String _kernelVer = '';

  static Future<void> init() async {
    try {
      // Try to read from ro.aiotool.hsr.* first (vendor custom props)
      _deviceName = await SystemProps.get('ro.aiotool.hsr.device_name', '');
      _chipset = await SystemProps.get('ro.aiotool.hsr.chipset', '');
      _kernelVer = await SystemProps.get('ro.aiotool.hsr.kernel_ver', '');
      
      // Fallback to standard Android Build properties
      if (_deviceName.isEmpty) {
        _deviceName = await SystemProps.get('ro.product.device', 
          await SystemProps.get('ro.build.product', 'Unknown'));
      }
      
      if (_chipset.isEmpty) {
        _chipset = await SystemProps.get('ro.chipname',
          await SystemProps.get('ro.hardware', 'Unknown'));
      }
      
      if (_kernelVer.isEmpty) {
        _kernelVer = await SystemProps.get('ro.kernel.version', 'Unknown');
      }

      _manufacturer = await SystemProps.get('ro.product.manufacturer', 'Unknown');
      _brand = await SystemProps.get('ro.product.brand', 'Unknown');
      _model = await SystemProps.get('ro.product.model', 'Unknown');
      _androidVer = await SystemProps.get('ro.build.version.release', 'Unknown');
    } catch (_) {
      // Use defaults if anything fails
      _deviceName = 'Unknown';
      _chipset = 'Unknown';
      _manufacturer = 'Unknown';
      _brand = 'Unknown';
      _model = 'Unknown';
      _androidVer = 'Unknown';
      _kernelVer = 'Unknown';
    }
  }

  static String get deviceName => _deviceName;
  static String get chipset => _chipset;
  static String get manufacturer => _manufacturer;
  static String get brand => _brand;
  static String get model => _model;
  static String get androidVer => _androidVer;
  static String get kernelVer => _kernelVer;
}
