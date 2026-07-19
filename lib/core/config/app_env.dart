import 'dart:convert';

import 'package:flutter/services.dart';

/// Carga `GEMINI_API_KEY` al arrancar la app.
///
/// Orden de resolución:
/// 1. `--dart-define=GEMINI_API_KEY=...` (CI / override)
/// 2. `env.json` empaquetado como asset (debug y release locales)
class AppEnv {
  AppEnv._();

  static String _geminiApiKey = '';

  static String get geminiApiKey {
    const fromDefine = String.fromEnvironment('GEMINI_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    return _geminiApiKey;
  }

  static Future<void> load() async {
    const fromDefine = String.fromEnvironment('GEMINI_API_KEY');
    if (fromDefine.isNotEmpty) {
      _geminiApiKey = fromDefine;
      return;
    }

    try {
      final raw = await rootBundle.loadString('env.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _geminiApiKey = (json['GEMINI_API_KEY'] as String? ?? '').trim();
    } catch (_) {
      _geminiApiKey = '';
    }
  }
}
