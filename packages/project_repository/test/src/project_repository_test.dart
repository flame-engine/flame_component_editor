import 'dart:convert';

import 'package:file_system_client/file_system_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_value_storage_client/key_value_storage_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_repository/project_repository.dart';

class _MockKeyValueStorageClient extends Mock implements KeyValueStorageClient;

class _MockFileSystemClient extends Mock implements FileSystemClient;

String _encode(List<String> paths) =>
    jsonEncode([for (final path in paths) Project(path: path).toJson()]);

void main() {
  group(ProjectRepository, () {
    const key = ProjectRepository.recentProjectsKey;

    late KeyValueStorageClient storage;
    late FileSystemClient fileSystem;
    late ProjectRepository repository;

    setUp(() {
      storage = _MockKeyValueStorageClient();
      fileSystem = _MockFileSystemClient();
      repository = ProjectRepository(storage: storage, fileSystem: fileSystem);

      when(() => storage.write(any(), any())).thenAnswer((_) async {});
      when(() => fileSystem.directoryExists(any()))
          .thenAnswer((_) async => true);
    });

    group('getRecentProjects', () {
      test('returns an empty list when nothing is stored', () async {
        when(() => storage.read(key)).thenAnswer((_) async => null);

        expect(await repository.getRecentProjects(), isEmpty);
      });

      test('returns an empty list when stored data is corrupt', () async {
        when(() => storage.read(key)).thenAnswer((_) async => 'not json');

        expect(await repository.getRecentProjects(), isEmpty);
      });

      test('returns the stored projects', () async {
        when(() => storage.read(key))
            .thenAnswer((_) async => _encode(['/a', '/b']));

        expect(
          await repository.getRecentProjects(),
          equals(const [Project(path: '/a'), Project(path: '/b')]),
        );
      });
    });

    group('pickProject', () {
      test('returns the picked project', () async {
        when(() => fileSystem.pickDirectory()).thenAnswer((_) async => '/a');

        expect(await repository.pickProject(), const Project(path: '/a'));
      });

      test('returns null when cancelled', () async {
        when(() => fileSystem.pickDirectory()).thenAnswer((_) async => null);

        expect(await repository.pickProject(), isNull);
      });
    });

    group('openProject', () {
      test('adds the project to the top of the recent projects', () async {
        when(() => storage.read(key)).thenAnswer((_) async => _encode(['/a']));

        await repository.openProject(const Project(path: '/b'));

        verify(() => storage.write(key, _encode(['/b', '/a']))).called(1);
      });

      test('moves an already recent project to the top', () async {
        when(() => storage.read(key))
            .thenAnswer((_) async => _encode(['/a', '/b', '/c']));

        await repository.openProject(const Project(path: '/b'));

        verify(() => storage.write(key, _encode(['/b', '/a', '/c']))).called(1);
      });

      test(
        'keeps at most ${ProjectRepository.maxRecentProjects} projects',
        () async {
          final paths = [for (var i = 0; i < 10; i++) '/$i'];
          when(() => storage.read(key)).thenAnswer((_) async => _encode(paths));

          await repository.openProject(const Project(path: '/new'));

          verify(() => storage.write(key, _encode(['/new', ...paths.take(9)])))
              .called(1);
        },
      );

      test(
        'removes the project and throws when its folder does not exist',
        () async {
          when(() => storage.read(key))
              .thenAnswer((_) async => _encode(['/a', '/b']));
          when(() => fileSystem.directoryExists('/b'))
              .thenAnswer((_) async => false);

          await expectLater(
            repository.openProject(const Project(path: '/b')),
            throwsA(
              isA<ProjectNotFoundException>().having(
                (e) => e.project,
                'project',
                const Project(path: '/b'),
              ),
            ),
          );
          verify(() => storage.write(key, _encode(['/a']))).called(1);
        },
      );
    });
  });
}
