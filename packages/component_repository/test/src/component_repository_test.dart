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
        when(() => fileSystem.listFiles(directory, extension: '.json'))
            .thenAnswer((_) async => [fileOf('Enemy')]);
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

      for (final name in [
        '',
        '1Player',
        'My Player',
        'a/b',
        '../x',
        '_',
        '_1',
      ]) {
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

      for (final name in ['Player', 'player', 'PLAYER']) {
        test('throws ComponentAlreadyExistsException for "$name" '
            'when Player exists', () {
          when(() => fileSystem.listFiles(directory, extension: '.json'))
              .thenAnswer((_) async => [fileOf('Player')]);

          expect(
            () => repository.createComponent(
              projectPath,
              name,
              ComponentType.rectangle,
            ),
            throwsA(isA<ComponentAlreadyExistsException>()),
          );
        });
      }
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

    group('writeComponentCode', () {
      const component = RectangleComponent(name: 'PlayerShip');
      const generator = ComponentCodeGenerator();
      final codeFile = p.join(
        projectPath,
        'lib/components',
        'player_ship.generated.dart',
      );

      setUp(() {
        when(() => fileSystem.writeFile(any(), any())).thenAnswer((_) async {});
      });

      test('writes the generated code to the output folder', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => false);

        await repository.writeComponentCode(
          projectPath,
          'lib/components',
          component,
        );

        verify(
          () => fileSystem.writeFile(codeFile, generator.generate(component)),
        ).called(1);
      });

      test('replaces previously generated code', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(codeFile))
            .thenAnswer((_) async => '${ComponentCodeGenerator.header}\n');

        await repository.writeComponentCode(
          projectPath,
          'lib/components',
          component,
        );

        verify(
          () => fileSystem.writeFile(codeFile, generator.generate(component)),
        ).called(1);
      });

      test('throws GeneratedFileConflictException and keeps a file that was '
          'not generated', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(codeFile))
            .thenAnswer((_) async => 'class PlayerShip {}');

        await expectLater(
          repository.writeComponentCode(
            projectPath,
            'lib/components',
            component,
          ),
          throwsA(
            isA<GeneratedFileConflictException>().having(
              (e) => e.path,
              'path',
              codeFile,
            ),
          ),
        );
        verifyNever(() => fileSystem.writeFile(any(), any()));
      });
    });

    group('deleteComponent', () {
      const component = RectangleComponent(name: 'Player');
      final codeFile = p.join(projectPath, 'lib/game', 'player.generated.dart');

      setUp(() {
        when(() => fileSystem.deleteFile(any())).thenAnswer((_) async {});
      });

      Future<void> delete() => repository.deleteComponent(
        projectPath,
        component,
        outputPath: 'lib/game',
      );

      test('deletes the component file and its generated code', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(codeFile))
            .thenAnswer((_) async => '${ComponentCodeGenerator.header}\n');

        await delete();

        verify(() => fileSystem.deleteFile(fileOf('Player'))).called(1);
        verify(() => fileSystem.deleteFile(codeFile)).called(1);
      });

      test('works when there is no generated code', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => false);

        await delete();

        verify(() => fileSystem.deleteFile(fileOf('Player'))).called(1);
        verifyNever(() => fileSystem.deleteFile(codeFile));
      });

      test('keeps a file that was not generated', () async {
        when(() => fileSystem.fileExists(codeFile))
            .thenAnswer((_) async => true);
        when(() => fileSystem.readFile(codeFile))
            .thenAnswer((_) async => 'class Player {}');

        await delete();

        verifyNever(() => fileSystem.deleteFile(codeFile));
      });
    });
  });
}
