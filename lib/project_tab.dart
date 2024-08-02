import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_toolbox/preferences.dart';
import 'package:serverpod_toolbox/widgets/command_row.dart';
import 'package:serverpod_toolbox/widgets/default_button.dart';
import 'package:tint/tint.dart';

import 'command_runner.dart';
import 'en.dart';

///
/// The project management tab
///
class ProjectTab extends StatefulWidget {
    const ProjectTab({super.key});

    @override
    State<ProjectTab> createState() => _ProjectTabState();
}

class _ProjectTabState extends State<ProjectTab> {
    static const double defaultControlSpacing = 2;
    final TextEditingController _logController = TextEditingController();
    late CommandRunner _commandRunner;
    String _projectFolderPath = "";
    late Preferences preferences;
    final _scrollController = ScrollController();
    bool _isLoading = false;
    late Future<void> _loadPreferencesFuture;

    @override
    void initState() {
        super.initState();
        _loadPreferencesFuture = loadPreferences();
    }

    ///
    /// Load the stored preferences
    ///
    Future<void> loadPreferences() async {
        preferences = Preferences();
        String? value = await preferences.loadProjectDir();
        setState(() {
                if (value == null) {
                    _projectFolderPath = "";
                } else {
                    _projectFolderPath = value;
                    _commandRunner = CommandRunner(_projectFolderPath, _logController, _addToLog);
                    _commandRunner.populateFolders();
                }
            });
    }

    @override
    Widget build(BuildContext context) {
        return FutureBuilder<void>(
            future: _loadPreferencesFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    // While waiting for the future to complete, show a loading indicator
                    return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                    // Handle errors if any
                    return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                    // Future completed successfully, build your form here
                    return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                            child: SizedBox(
                                height: 900.0, // size of the scrollable area
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                        SingleChildScrollView(
                                            child: SizedBox(
                                                height: 720.0, // size of the scrollable area
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                        _buildProjectFolderSelector(),
                                                        ...buildDivider(),
                                                        const SizedBox(height: defaultControlSpacing),
                                                        _buildFlutterUpgradeButton(),
                                                        ...buildDivider(),
                                                        _buildUpgradeCLIButton(),
                                                        ...buildDivider(),
                                                        _buildServerpodGenerateButton(),
                                                        ...buildDivider(),
                                                        _buildServerpodCreateMigrationButton(),
                                                        ...buildDivider(),
                                                        _buildServerpodBuildRunnerButton(),
                                                        ...buildDivider(),
                                                        _buildCreateRepairMigrationButton(),
                                                        ...buildDivider(),
                                                        _buildFlutterCleanButton(),
                                                        ...buildDivider(),
                                                        _buildFlutterGetPubButton(),
                                                        ...buildDivider(),
                                                        _buildFixDartFormatterButton(),
                                                        ...buildDivider(),
                                                    ],
                                                ),
                                            ),
                                        ),
                                        _buildLogOutputArea(),
                                        const SizedBox(height: defaultControlSpacing),
                                        buildClearLogButton(),
                                    ],
                                ),
                            ),
                        ));
                }
            });
    }

    ///
    /// Build the project folder text field and folder selector button
    ///
    SizedBox _buildProjectFolderSelector() {
        double? totalWidth = 900;
        return SizedBox(
            width: totalWidth,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(
                        width: totalWidth - 100,
                        child: TextField(
                            controller: TextEditingController(text: _projectFolderPath), // Set initial text
                            decoration: const InputDecoration(
                                labelText: 'Top Level Project folder',
                                border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                                // Update the state with the entered text
                                _projectFolderPath = value;
                                preferences.saveProjectDir(_projectFolderPath);
                            },
                        ),
                    ),
                    const SizedBox(width: 10),
                    DefaultButton(
                        onPressed: () async {
                            final selectedDirectory = await _getDirectoryPicker();
                            if (selectedDirectory != null) {
                                setState(() {
                                        _projectFolderPath = selectedDirectory;
                                    });
                                preferences.saveProjectDir(_projectFolderPath);
                            }
                        },
                        text: '...',
                        isLoading: _isLoading,
                    ),
                ]),
        );
    }

    ///
    /// Build the flutter upgrade button
    ///
    CommandRow _buildFlutterUpgradeButton() {
        return CommandRow(
            context: context,
            label: "Upgrade flutter version, you can use --force if there are major changes.",
            commandText: CommandRunner.flutterPubUpgrade,
            onPlayPressed: _commandRunner.flutterUpgrade,
            infoHtmlBody: flutterUpgradeHtml,
            isLoading: _isLoading,
        );
    }

    ///
    /// Build the 'upgrade CLI version' button
    ///
    CommandRow _buildUpgradeCLIButton() {
        return CommandRow(
            context: context,
            label: "Upgrade flutter CLI version, required if upgrading flutter.   ",
            commandText: upgradeCliText,
            onPlayPressed: _commandRunner.runUpgradeCLI,
            infoHtmlBody: upgradeCliHtml,
            isLoading: _isLoading,
        );
    }

    ///
    /// Build serverpod generate button
    ///
    CommandRow _buildServerpodGenerateButton() {
        return CommandRow(
            context: context,
            label: "Generate model (model db classes) and end point code.",
            commandText: serverpodGenerateTitle,
            onPlayPressed: () async {
                _setLoading(true);
                await _commandRunner.serverPodGenerate();
                _setLoading(false);
            },
            infoHtmlBody: serverpodGenerateHtml,
            isLoading: _isLoading,
        );
    }

    ///
    /// Build the create migration button, with a secondary --force create migration button
    ///
    CommandRow _buildServerpodCreateMigrationButton() {
        return CommandRow(
            context: context,
            label: "Create an upgrade script for your db with the latest changes to the models.\n"
            "Make sure 'main.dart --apply-migrations' is run on the next restart.",
            commandText: CommandRunner.serverpodCreateMigrationCommand,
            onPlayPressed: () async {
                _isLoading = true;
                await _commandRunner.serverpodCreateMigration();
                _isLoading = false;
            },
            infoHtmlBody: createMigrationHtml,
            isLoading: _isLoading,
            secondaryCommandText: '${CommandRunner.serverpodCreateMigrationCommand} --force (WARNING)',
            onSecondaryPlayPressed: () async {
                _isLoading = true;
                _showMigrationForceWarning(context);
                _isLoading = false;
            },
        );
    }

    ///
    /// Shows a warning on 'create-migration --force'
    ///
    void _showMigrationForceWarning(BuildContext context) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Warning'),
                content: const Text(
                    "Using the --force command will drop and rebuild any tables that can't be migrated.",
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context), // Close dialog
                        child: const Text('Cancel'),
                    ),
                    TextButton(
                        onPressed: () {
                            Navigator.pop(context);
                            _commandRunner.serverpodCreateMigration('--force');
                        },
                        child: const Text('Continue'),
                    ),
                ],
            ));
    }

    ///
    /// Build the 'dart run build_runner build --release' button
    ///
    CommandRow _buildServerpodBuildRunnerButton() {
        return CommandRow(
            context: context,
            label: "Build server deployment, it will also update generated mock tests",
            commandText: CommandRunner.buildRunnerCommand,
            onPlayPressed: () async {
                _isLoading = true;
                await _commandRunner.buildRunner();
                _isLoading = false;
            },
            infoHtmlBody: buildRunnerHtml,
            isLoading: _isLoading,
            secondaryCommandText: '${CommandRunner.buildRunnerCommand} --release',
            onSecondaryPlayPressed: () async {
                _isLoading = true;
                await _commandRunner.buildRunner('--release');
                _isLoading = false;
            },
        );
    }

    ///
    /// Build the repair migration row
    ///
    CommandRow _buildCreateRepairMigrationButton() {
        return CommandRow(
            context: context,
            label:
            "Create a repair script of the db schema using the model yaml.\nThis will need to applied on the next server run, or by using the --apply-repair-migration here",
            commandText: serverpodCreateRepairMigrationTitle,
            onPlayPressed: () async {
                _isLoading = true;
                await _commandRunner.serverpodCreateRepairMigration();
                _isLoading = false;
            },
            infoHtmlBody: serverpodCreateRepairMigrationHtml,
            isLoading: _isLoading,
            secondaryCommandText: CommandRunner.serverpodApplyRepairMigrationCommand, //serverpodApplyRepairMigrationTitle,
            onSecondaryPlayPressed: () async {
                _isLoading = true;
                await _commandRunner.serverpodApplyRepairMigration();
                _isLoading = false;
            },
        );
    }

    ///
    /// Build clean button
    ///
    /// Cleans the library files in all project folders.
    ///
    CommandRow _buildFlutterCleanButton() {
        return CommandRow(
            context: context,
            label: "Cleans the library files in all project folders.",
            commandText: flutterCleanTitle,
            onPlayPressed: () async {
                _isLoading = true;
                await _commandRunner.flutterClean();
                _isLoading = false;
            },
            infoHtmlBody: flutterCleanHtml,
            isLoading: _isLoading,
        );
    }

    ///
    /// Build  flutter get pub
    ///
    CommandRow _buildFlutterGetPubButton() {
        return CommandRow(
            context: context,
            label: "Get the latest/upgraded libraries across all 4 project folders.",
            commandText: flutterGetTitle,
            onPlayPressed: () async {
                _isLoading = true;
                await _commandRunner.flutterGet();
                _isLoading = false;
            },
            infoHtmlBody: flutterGetHtml,
            isLoading: _isLoading,
        );
    }

    ///
    /// Fix the dart_format plugin for intellij
    ///
    CommandRow _buildFixDartFormatterButton() {
        return CommandRow(
            context: context,
            label: "Fix dart_format plugin for IntelliJ.",
            commandText: CommandRunner.fixDartFormat,
            onPlayPressed: () async {
                _isLoading = true;
                await _commandRunner.runFixDartFormat();
                _isLoading = false;
            },
            infoHtmlBody: fixDartFormatHtml,
            isLoading: _isLoading,
        );
    }

    ///
    /// Clear log button
    ///
    Row buildClearLogButton() {
        return Row(
            children: [
                DefaultButton(
                    onPressed: () {
                        setState(() {
                                _logController.text = ''; // Clear the text controller
                            });
                    },
                    text: 'Clear log output',
                    isLoading: _isLoading,
                ),
            ],
        );
    }

    ///
    /// Build the log output area
    ///
    Expanded _buildLogOutputArea() {
        return Expanded(
            child: NotificationListener<ScrollNotification>(
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                    ),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxHeight: 500.0, // Adjust maxHeight for desired size
                        ),
                        child: ListView(
                            controller: _scrollController, // Create a ScrollController
                            children: [
                                TextField(
                                    controller: _logController,
                                    readOnly: true,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Log Output',
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    ///
    /// Add text to the log area
    ///
    void _addToLog(var rawOutput) {
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

        setState(() {
                _logController.text += '$message\n';
                // Scroll the text area to the bottom after updating the text
                _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            });
    }

    @override
    void dispose() {
        _logController.dispose();
        _scrollController.dispose();
        super.dispose();
    }

    ///
    /// Divider and spacer
    ///
    List<Widget> buildDivider() {
        return [
            const Divider(
                // Add divider line here
                thickness: 1, // Adjust thickness as needed
                color: Colors.grey, // Adjust color as needed
            ),
            const SizedBox(height: defaultControlSpacing)
        ];
    }

    void _setLoading(bool isLoading) {
        setState(() {
                _isLoading = isLoading;
            });
    }

    ///
    /// Directory picker selection
    ///
    Future<String?> _getDirectoryPicker() {
        return (Platform.isWindows) ? _getDirectoryPathWindows() : _getDirectoryPathLinux();
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
    /// Directory picker selection for Linux
    ///
    Future<String?> _getDirectoryPathLinux() async {
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

}
