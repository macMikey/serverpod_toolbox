import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

///
/// Runs a command using cmd.exe
///
class CommandRunner {
    String projectDir;
    TextEditingController logController;
    Function logAppender;

    // List of project folders
    List<String> serverpodFolders = [];
    late String _projectFolderServer;
    late String _projectFolderFlutter;
    late String _projectFolderClient;
    late String _projectFolderShared;

    // All the commands available to run.  Set to public so they can be used as button labels
    static String flutterPubUpgrade = 'flutter pub upgrade --major-versions';
    static String fixDartFormat = 'dart pub global activate dart_format';
    static String upgradeCLI = 'dart pub global activate serverpod_cli';
    static const String flutterCleanCommand = 'flutter clean';
    static const String serverpodGenerateCommand = 'serverpod generate';
    static const String serverpodCreateMigrationCommand = 'serverpod create-migration';
    static const String buildRunnerCommand = 'dart run build_runner build';
    static const String serverpodCreateRepairMigrationCommand = 'serverpod create-repair-migration';
    static const String serverpodApplyRepairMigrationCommand = 'dart run bin/main.dart --apply-repair-migration';

    CommandRunner(this.projectDir, this.logController, this.logAppender);

    ///
    /// Populate the directories
    ///
    Future<void> populateFolders() async {
        if (projectDir.endsWith(Platform.pathSeparator)) {
            throw Exception("Project dir must not end with a slash");
        }
        // get the project name
        final segments = projectDir.split(Platform.pathSeparator);
        String projectName = segments.last;

        // add an ending directory separator
        // if (!projectDir.endsWith(Platform.pathSeparator)) {
        //     projectDir += Platform.pathSeparator;
        // }

        // build the project dirs
        _projectFolderServer = "${projectName}_server";
        _projectFolderFlutter = "${projectName}_flutter";
        _projectFolderClient = "${projectName}_client";

        // build a list of project dirs
        serverpodFolders = [_projectFolderServer, _projectFolderFlutter, _projectFolderClient];

        // Add the  'project_shared' folder if it exists
        String sharedDir = "${projectName}_shared";
        bool sharedFolderExists = await Directory(sharedDir).exists();
        if (sharedFolderExists) {
            _projectFolderShared = "${projectName}_shared";
            serverpodFolders.add(_projectFolderShared);
        }
    }

    ///
    /// Run an OS command
    ///
    Future<void> _runCommand(String command, {String subFolder = ""}) async {
        try {
            Process.start('cmd', ['/c', command]).then((process) => process.stdout.pipe(stdout));

            final process = await Process.start('cmd', ['/c', command], workingDirectory: "$projectDir${Platform.pathSeparator}$subFolder");
            logAppender("Running:\n $projectDir${Platform.pathSeparator}$subFolder${Platform.pathSeparator}$command");
            process.stdout.transform(utf8.decoder).listen((line) => logAppender(line)); // Log each line
            await process.exitCode; // Wait for process to finish
        } catch (e) {
            logAppender('Error executing command: $command\n$e');
        }
    }

    Future<void> flutterClean() async {
        for (final folder in serverpodFolders) {
            await _runCommand(flutterCleanCommand, subFolder: folder);
        }
        _processLog();
    }

    Future<void> flutterGet() async {
        for (final folder in serverpodFolders) {
            await _runCommand('dart pub get', subFolder: folder);
        }

        _processLog();
    }

    Future<void> flutterUpgrade() async {
        for (final folder in serverpodFolders) {
            await _runCommand(flutterPubUpgrade, subFolder: folder);
        }
        _processLog();
    }

    Future<void> serverPodGenerate() async {
        await _runCommand(serverpodGenerateCommand, subFolder: _projectFolderServer);
        _processLog();
    }

    Future<void> runUpgradeCLI() async {
        await _runCommand(upgradeCLI);
        _processLog();
    }

    Future<void> serverpodCreateMigration([String? force]) async {
        await _runCommand("$serverpodCreateMigrationCommand $force", subFolder: _projectFolderServer);
        _processLog();
    }

    Future<void> buildRunner([String? release]) async {
        await _runCommand("$buildRunnerCommand $release", subFolder: _projectFolderServer);
        _processLog();
    }

    Future<void> serverpodCreateRepairMigration() async {
        await _runCommand(serverpodCreateRepairMigrationCommand, subFolder: _projectFolderServer);
        _processLog();
    }

    Future<void> serverpodApplyRepairMigration() async {
        await _runCommand(serverpodApplyRepairMigrationCommand, subFolder: _projectFolderServer);
        _processLog();
    }

    Future<void> runFixDartFormat() async {
        await _runCommand(fixDartFormat);
        _processLog();
    }

    void _processLog() {
        logAppender("**** Finished ******");
    }
}
