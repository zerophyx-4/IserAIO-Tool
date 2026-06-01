import 'package:flutter/services.dart';

class DaemonClient {
  static const MethodChannel _channel = MethodChannel('com.hsr.isertoolkit/daemon');

  static Future<String> sendCommand(String cmd, String value) async {
    try {
      final result = await _channel.invokeMethod('sendCommand', {'command': cmd, 'value': value});
      return result?.toString() ?? 'FAIL';
    } catch (_) {
      return 'FAIL';
    }
  }

  static Future<String> setProfile(String profile) => sendCommand('SET_PROFILE', profile);
  static Future<String> setThermal(bool enabled) => sendCommand('SET_THERMAL', enabled ? '1' : '0');
  static Future<String> setFrontFlash(bool enabled) => sendCommand('SET_FRONTFLASH', enabled ? '1' : '0');
  static Future<String> setAnimation(String scale) => sendCommand('SET_ANIMATION', scale);
  static Future<String> killBackground() => sendCommand('KILL_BG', '');
  static Future<String> getStatus() => sendCommand('GET_STATUS', '');
}