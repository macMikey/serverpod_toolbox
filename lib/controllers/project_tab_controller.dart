import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:serverpod_toolbox/models/preferences.dart';
import 'package:tint/tint.dart';

import 'command_runner.dart';

class ProjectTabController {
    late Preferences preferences;
    late CommandRunner commandRunner;
    String projectFolderPath = "";
    final TextEditingController logController;

    ProjectTabController(this.logController);

    ///
    /// Load the stored preferences
    ///
    Future<void> loadPreferences() async {
        preferences = Preferences();
        String? value = await preferences.loadProjectDir();

        if (value == null) {
            projectFolderPath = "";
        } else {
            projectFolderPath = value;
            commandRunner = CommandRunner(projectFolderPath, logController, _addToLog);
            commandRunner.populateFolders();
        }
    }

    ///
    /// Handle the project folder selection
    ///
    Future<void> handleProjectFolderSelector(BuildContext context, Function setStateCallback) async {
        final selectedDirectory = await _getDirectoryPicker(context);
        if (selectedDirectory != null) {
            setStateCallback(() {
                projectFolderPath = selectedDirectory;
            });
            await preferences.saveProjectDir(projectFolderPath);
        }
    }

    ///
    /// Directory picker selection
    ///
    Future<String?> _getDirectoryPicker(BuildContext context) {
        return (Platform.isWindows) ? _getDirectoryPathWindows() : _getDirectoryPathLinux(context);
    }


    ///
    /// Directory picker selection for Linux
    ///
    Future<String?> _getDirectoryPathLinux(BuildContext context) async {
        final result = await FilesystemPicker.open(
            context: context,
            //rootDirectory: Directory("/"), // Optional: Set initial directory
            fsType: FilesystemType.folder, // Specify directory selection
        );

        if (result != null) {
            return result; // This is the selected directory path
        } else {
            // Handle case where user cancels or there's an error
            return null;
        }
    }

    ///
    /// Directory picker selection for windows
    ///
    Future<String?> _getDirectoryPathWindows() {
        final Completer<String?> completer = Completer<String?>();

        // Use DirectoryPicker to open the directory picker dialog
        final directoryPicker = DirectoryPicker()..title = 'Select a directory';

        // Show the directory picker dialog
        Future.microtask(() {
            final selectedDirectory = directoryPicker.getDirectory();
            if (selectedDirectory != null) {
                // Complete the Future with the selected directory path
                completer.complete(selectedDirectory.path);
            } else {
                // Complete the Future with null if no directory was selected
                completer.complete(null);
            }
        });
        return completer.future;
    }

    ///
    /// Add text to the log area
    ///
    void _addToLog(dynamic rawOutput) {
        String message = "";

        if (rawOutput is Uint8List) {
            // The output line is UTF8
            final String text = utf8.decode(rawOutput);
            // remove the ansi escape colours (.strip() is an extension method from the Tint library)
            message = text.strip();
        } else if (rawOutput is String) {
            message = rawOutput;
        } else {
            message = rawOutput.toString();
        }

        logController.text += '$message\n';
    }


    ///
    /// Update the project with the entered text
    ///
    void updateProjectFolder(String value) {
        projectFolderPath = value;
        preferences.saveProjectDir(projectFolderPath);
    }
}
