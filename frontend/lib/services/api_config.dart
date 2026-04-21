import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class ApiConfig {
  // Override at build/run time with:
  // `--dart-define=API_BASE_URL=http://YOUR_IP:8080`
  static const String androidEmulator = "http://192.168.100.10:8080";
  static const String localhost = "http://192.168.100.10:8080";

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (override.isNotEmpty) return override;

    if (kIsWeb) return localhost;

    return "http://192.168.100.10:8080";
  }

}
