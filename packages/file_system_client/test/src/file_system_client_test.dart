import 'dart:io';

import 'package:file_system_client/file_system_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(FileSystemClient, () {
    test('can be instantiated without a directory picker', () {
      expect(FileSystemClient.new, returnsNormally);
    });

    group('pickDirectory', () {
      test('returns the picked path', () async {
        final client = FileSystemClient(directoryPicker: () async => '/a/b');

        expect(await client.pickDirectory(), equals('/a/b'));
      });

      test('returns null when cancelled', () async {
        final client = FileSystemClient(directoryPicker: () async => null);

        expect(await client.pickDirectory(), isNull);
      });
    });

    group('directoryExists', () {
      test('returns true for an existing directory', () async {
        final directory = Directory.systemTemp.createTempSync();
        addTearDown(() => directory.deleteSync(recursive: true));

        expect(
          await FileSystemClient().directoryExists(directory.path),
          isTrue,
        );
      });

      test('returns false for a missing directory', () async {
        final directory = Directory.systemTemp.createTempSync()..deleteSync();

        expect(
          await FileSystemClient().directoryExists(directory.path),
          isFalse,
        );
      });
    });
  });
}
