import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-only tracing — a no-op in release builds so internal identifiers
/// (uids, stack traces) never reach production logs.
void logTrace(String tag, String message) {
  if (!kDebugMode) return;
  developer.log(message, name: tag);
}
