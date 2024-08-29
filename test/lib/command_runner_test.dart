import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:serverpod_toolbox/controllers/command_runner.dart';
import 'package:test/test.dart';

// import '../command_runner_test.mocks.dart';

// @GenerateMocks([Directory, TextEditingController, Function]) // Generate mock classes
void main() {
    // late MockDirectory mockDirectory;
    // late MockTextEditingController mockLogController;
    // late MockFunction mockLogAppender;

    late Directory mockDirectory;
    late TextEditingController mockLogController;

    setUp(() async {
            // mockDirectory = MockDirectory();
            // mockLogController = MockTextEditingController();
            // mockLogAppender = MockFunction();
            mockDirectory = Directory('${Directory.current.path}\\test\\mock_project');
            mockLogController = TextEditingController();
        });

    test('should populate project folders correctly', () async {
            //   const projectDir = '..\\mock_project';

            // when(mockDirectory.existsSync()).thenReturn(true);

            final commandRunner = CommandRunner(mockDirectory.path, mockLogController, () {});
            await commandRunner.populateFolders();
            //     expect(commandRunner.projectFolderShared, null); // Shared folder not populated yet

            // Simulate asynchronous response for shared folder existence
            // verify(mockDirectory.existsSync(verifiableByName: 'shared folder check')).call(arguments: ['path/to/myproject/_shared']);
            //commandRunner.logAppender(const LogMessage('Shared folder check simulated'));

            expect(commandRunner.serverpodFolders.length, 4); // Now includes shared folder
            //   expect(commandRunner.projectFolderShared, '${projectName}_shared');
        });

    test('should not populate shared folder if it does not exist', () {
            const projectDir = '..\\mock_project';

            //   when(mockDirectory.existsSync()).thenReturn(true); // Mock base folders exist
            //   when(mockDirectory.existsSync(verifiableByName: 'shared folder check')).thenReturn(false); // Mock shared folder doesn't exist

            final commandRunner = CommandRunner(projectDir, mockLogController, () {});

            expect(commandRunner.serverpodFolders.length, 3); // Only base 3 folders
        });
}
