import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:serverpod_toolbox/controllers/command_runner.dart';
import 'package:test/test.dart';

void main() {
    late Directory mockDirectory;
    late TextEditingController mockLogController;

    setUp(() async {
            mockDirectory = Directory('${Directory.current.path}\\test\\mock_project');
            mockLogController = TextEditingController();
        });

    test('should populate project folders correctly', () async {
            final commandRunner = CommandRunner(mockDirectory.path, ()=>{});
            await commandRunner.populateFolders();
            expect(commandRunner.serverpodFolders.length, 4); 
        });

}
