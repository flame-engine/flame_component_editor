import 'dart:convert';

import 'package:component_repository/component_repository.dart';
import 'package:file_system_client/file_system_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;

class _MockFileSystemClient extends Mock implements FileSystemClient;

void main() {
  group(ComponentRepository, () {
    const projectPath = '/projects/my_game';
    final directory = p.join(
      projectPath,
      ComponentRepository.componentsDirectory,
    );
    String fileOf(String name) => p.join(directory, '$name.json');

    late FileSystemClient fileSystem;
    late ComponentRepository repository;

    setUp(() {
      fileSystem = _MockFileSystemClient();
      repository = ComponentRepository(fileSystem: fileSystem);
    });

    group('getComponents', () {
      test('returns the components sorted by name', () async {
        when(() => fileSystem.listFiles(directory, extension: '.json'))
            .thenAnswer((_) async => [fileOf('Player'), fileOf('Enemy')]);
        when(() => fileSystem.readFile(fileOf('Player')))
            .thenAnswer((_) async => jsonEncode({'name': 'Player'}));
        when(() => fileSystem.readFile(fileOf('Enemy')))
            .thenAnswer((_) async => jsonEncode({'name': 'Enemy'}));

        expect(
          await repository.getComponents(projectPath),
          equals(const [
            RectangleComponent(name: 'Enemy'),
            RectangleComponent(name: 'Player'),
          ]),
        );
      });

      test('skips unreadable files', () async {
        when(() => fileSystem.listFiles(directory, extension: '.json'))
            .thenAnswer((_) async => [fileOf('Player'), fileOf('Broken')]);
        when(() => fileSystem.readFile(fileOf('Player')))
            .thenAnswer((_) async => jsonEncode({'name': 'Player'}));
        when(() => fileSystem.readFile(fileOf('Broken')))
            .thenAnswer((_) async => 'not json');

        expect(
          await repository.getComponents(projectPath),
          equals(const [RectangleComponent(name: 'Player')]),
        );
      });
    });

    group('createComponent', () {
      test('writes the component file and returns the component', () async {
        when(() => fileSystem.fileExists(fileOf('Player')))
            .thenAnswer((_) async => false);
        when(() => fileSystem.writeFile(any(), any())).thenAnswer((_) async {});

        expect(
          await repository.createComponent(
            projectPath,
            'Player',
            ComponentType.rectangle,
          ),
          equals(const RectangleComponent(name: 'Player')),
        );
        verify(
          () => fileSystem.writeFile(
            fileOf('Player'),
            jsonEncode(const RectangleComponent(name: 'Player').toJson()),
          ),
        ).called(1);
      });

      for (final name in ['', '1Player', 'My Player', 'a/b', '../x']) {
        test('throws InvalidComponentNameException for "$name"', () {
          expect(
            () => repository.createComponent(
              projectPath,
              name,
              ComponentType.rectangle,
            ),
            throwsA(isA<InvalidComponentNameException>()),
          );
        });
      }

      test('throws ComponentAlreadyExistsException when it exists', () {
        when(() => fileSystem.fileExists(fileOf('Player')))
            .thenAnswer((_) async => true);

        expect(
          () => repository.createComponent(
            projectPath,
            'Player',
            ComponentType.rectangle,
          ),
          throwsA(isA<ComponentAlreadyExistsException>()),
        );
      });
    });

    group('saveComponent', () {
      test('writes the component file', () async {
        when(() => fileSystem.writeFile(any(), any())).thenAnswer((_) async {});
        const component = RectangleComponent(
          name: 'Player',
          size: ComponentSize(width: 10, height: 20),
        );

        await repository.saveComponent(projectPath, component);

        verify(
          () => fileSystem.writeFile(
            fileOf('Player'),
            jsonEncode(component.toJson()),
          ),
        ).called(1);
      });
    });

    group('deleteComponent', () {
      test('deletes the component file', () async {
        when(() => fileSystem.deleteFile(any())).thenAnswer((_) async {});

        await repository.deleteComponent(
          projectPath,
          const RectangleComponent(name: 'Player'),
        );

        verify(() => fileSystem.deleteFile(fileOf('Player'))).called(1);
      });
    });
  });
}
