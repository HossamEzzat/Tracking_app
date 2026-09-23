import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth code does not use plain storage or log secrets', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final source = file.readAsStringSync();
      expect(source.contains('shared_preferences'), isFalse, reason: file.path);
      expect(source.contains('package:hive'), isFalse, reason: file.path);
      expect(source.contains('print('), isFalse, reason: file.path);
      _expectLogsDoNotContainSecrets(file.path, source);
    }
  });
}

void _expectLogsDoNotContainSecrets(String path, String source) {
  for (final line in source.split('\n')) {
    final lower = line.toLowerCase();
    final logs =
        lower.contains('developer.log') || lower.contains('debugprint');
    if (!logs) continue;
    expect(lower.contains('accesstoken'), isFalse, reason: path);
    expect(lower.contains('refreshtoken'), isFalse, reason: path);
    expect(lower.contains('password'), isFalse, reason: path);
  }
}
