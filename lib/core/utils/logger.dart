import 'package:flutter/foundation.dart';

void appLog(String message, {bool error = false}) {
  final prefix = error ? '[❌ ERROR]' : '[ℹ️ LOG]';
  if (kDebugMode) {
    debugPrint('$prefix $message');
  }
}
