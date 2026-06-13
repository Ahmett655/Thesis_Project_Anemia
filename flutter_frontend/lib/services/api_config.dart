import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Central place for the backend host.
///
/// - Web (Chrome on the same computer): `localhost` always works.
/// - Android emulator: `10.0.2.2` maps to the host machine.
/// - Physical phone over Wi-Fi: needs the computer's LAN IP.
///
/// If your phone can't connect, update [lanIp] to your computer's current
/// IPv4 address (run `ipconfig` and read the "IPv4 Address" line). This is
/// the ONLY place you need to change it.
class ApiConfig {
  /// Computer's current LAN IP — used by physical devices only.
  static const String lanIp = '192.168.18.65';

  static const int port = 3000;

  /// host:port for the active platform.
  static String get host {
    if (kIsWeb) return 'localhost:$port';
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Physical Android phone reaches the host via the LAN IP.
      // (If you use the emulator instead, change this to '10.0.2.2:$port'.)
      return '$lanIp:$port';
    }
    // iOS / desktop
    return 'localhost:$port';
  }

  static String get apiBase => 'http://$host/api';
}
