import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// Where the app finds the two backend services.
///
/// Both default to `localhost`, which works when running on a desktop
/// target, iOS Simulator, or a physical device connected via `adb reverse`.
/// It does **not** work on the Android emulator: inside the emulator's own
/// network namespace, `localhost` points at the emulator itself, not your
/// host machine where `docker compose up` is actually listening. Android
/// provides a special alias, `10.0.2.2`, that always reaches the host's
/// localhost from inside the emulator — so that's used automatically
/// whenever the app detects it's running on Android.
///
/// Override either at run/build time if you need something else, e.g. a
/// physical device on the same Wi-Fi as your machine (use your machine's
/// LAN IP instead):
///   flutter run --dart-define=CORE_API_URL=http://192.168.1.23:8080/api/v1
class Environment {
  static const _coreApiUrlOverride =
      String.fromEnvironment('CORE_API_URL', defaultValue: '');
  static const _intelligenceApiUrlOverride =
      String.fromEnvironment('INTELLIGENCE_API_URL', defaultValue: '');

  static String get _host =>
      defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';

  static String get coreApiUrl => _coreApiUrlOverride.isNotEmpty
      ? _coreApiUrlOverride
      : 'http://$_host:8080/api/v1';

  static String get intelligenceApiUrl => _intelligenceApiUrlOverride.isNotEmpty
      ? _intelligenceApiUrlOverride
      : 'http://$_host:8000/api/v1';
}
