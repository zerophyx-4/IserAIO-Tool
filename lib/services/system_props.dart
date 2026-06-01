import 'package:flutter/services.dart';

class SystemProps {
  static const MethodChannel _channel = MethodChannel('com.hsr.isertoolkit/props');

  static Future<String> get(String key, String defaultVal) async {
    try {
      final result = await _channel.invokeMethod('getprop', {'key': key, 'default': defaultVal});
      return result?.toString() ?? defaultVal;
    } catch (_) {
      return defaultVal;
    }
  }

  static Future<bool> set(String key, String value) async {
    try {
      await _channel.invokeMethod('setprop', {'key': key, 'value': value});
      return true;
    } catch (_) {
      return false;
    }
  }
}