import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tiny, UI-only controller for the app's light/dark preference. It holds
/// no business logic and touches no API/session state — it just remembers
/// which [ThemeMode] the person picked and persists that choice locally
/// (via the secure storage the app already depends on) so it survives a
/// restart. [EnqivraApp] listens to this to pick which ThemeData to hand
/// to MaterialApp; [ThemeToggleButton] is the only thing that calls [toggle].
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._() : super(ThemeMode.dark) {
    _restore();
  }

  static final ThemeController instance = ThemeController._();

  static const _storageKey = 'enqivra.theme_mode';
  final _storage = const FlutterSecureStorage();

  bool get isDark => value == ThemeMode.dark;

  Future<void> _restore() async {
    try {
      final saved = await _storage.read(key: _storageKey);
      if (saved == 'light') {
        value = ThemeMode.light;
      } else if (saved == 'dark') {
        value = ThemeMode.dark;
      }
    } catch (_) {
      // No stored preference yet, or storage unavailable — keep default.
    }
  }

  /// Flips the mode. The actual on-screen animation is owned by whoever
  /// calls this (see ThemeToggleButton, which wraps it in the circular
  /// reveal); this method only updates + persists the value.
  Future<void> toggle() async {
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    value = next;
    try {
      await _storage.write(
          key: _storageKey, value: next == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {
      // Persistence is a nice-to-have; a failure here shouldn't block the
      // theme switch the person just asked for.
    }
  }
}
