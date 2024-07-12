import 'dart:convert';
import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_toolbox/preferences.dart';
import 'package:serverpod_toolbox/widgets/default_button.dart';
import 'package:tint/tint.dart';

import 'command_runner.dart';
import 'en.dart';
import 'info_box.dart';

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
    late final _projectDirectoryPicker; //= DirectoryPicker()..title = 'Select a directory';
    String _projectFolderPath = "";
    late Preferences preferences;
    final _scrollController = ScrollController();
    bool _isLoading = false;

    setupDirectoryPicker() {
        _projectDirectoryPicker = (Platform.isWindows) ? _getDirectoryPathWindows() : _getDirectoryPathLinux();

        // if (_projectDirectoryPicker != null) {
        // Use the selected directory path here
        //  } else {
        // Handle case where user cancels or there's an error
        //  }
    }

    Future<DirectoryPicker> _getDirectoryPathWindows() async {
        final directory = DirectoryPicker()..title = 'Select a directory';
        return directory;
    }

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

    @override
    void initState() {
        super.initState();

        loadPreferences();
    }

    ///
    /// Load the stored preferences
    ///
    void loadPreferences() {
        preferences = Preferences();
        preferences.loadProjectDir().then((value) {
                setState(() {
                        if (value == null) {
                            _projectFolderPath = "";
                        } else {
                            _projectFolderPath = value;
                            _commandRunner = CommandRunner(_projectFolderPath, _logController, _addToLog);
                            _commandRunner.populateFolders();
                        }
                    });
            });
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(20.0),
            child:  SingleChildScrollView(
                child: SizedBox(
                    height: 900.0, // size of the scrollable area
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                            SingleChildScrollView(
                                child: SizedBox(
                                    height: 600.0, // size of the scrollable area
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
                    DefaultButton(
                        onPressed: () {
                            final result = _projectDirectoryPicker.getDirectory();
                            if (result != null) {
                                setState(() {
                                        _projectFolderPath = result.path;
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
    ///
    Row _buildFlutterUpgradeButton() {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align content on opposite ends
            children: [
                const Expanded(
                    child: SelectableText(
                        "Upgrade flutter version, you can use --force if there are major changes.",
                    ),
                ),
                DefaultButton(
                    onPressed: () async {
                        _isLoading = true;
                        await _commandRunner.flutterUpgrade();
                        _isLoading = false;
                    },
                    text: CommandRunner.flutterPubUpgrade, // Changed button text
                    isLoading: _isLoading,
                ),
                IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showInfoPopup(
                        CommandRunner.flutterPubUpgrade,
                        flutterUpgradeHtml,
                    ),
                ),
            ],
        );
    }

    ///
    /// Build the 'upgrade CLI version' button
    ///
    Row _buildUpgradeCLIButton() {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                const Expanded(
                    child: SelectableText(
                        "Upgrade flutter CLI version, required if upgrading flutter.   ",
                    ),
                ),
                DefaultButton(
                    onPressed: () async {
                        _isLoading = true;
                        await _commandRunner.runUpgradeCLI();
                        _isLoading = false;
                    },
                    text: upgradeCliTitle,
                    isLoading: _isLoading,
                ),
                IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showInfoPopup(
                        upgradeCliTitle,
                        upgradeCliHtml,
                    ),
                ),
            ],
        );
    }

    ///
    /// Build serverpod generate button
    ///
    Widget _buildServerpodGenerateButton() {
        return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Expanded(
                    child: SelectableText("Generate model (model db classes) and end point code."),
                ),
                DefaultButton(
                    onPressed: () async {
                        _isLoading = true;
                        await _commandRunner.serverPodGenerate();
                        _isLoading = false;
                    },
                    text: serverpodGenerateTitle,
                    isLoading: _isLoading,
                ),
                IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showInfoPopup(
                        serverpodGenerateTitle,
                        serverpodGenerateHtml,
                    ),
                ),
            ]);
    }

    ///
    /// Build the create migration button
    ///
    Widget _buildServerpodCreateMigrationButton() {
        return Row(children: [
                const Expanded(
                    child: SelectableText("Create an upgrade script for your db with the latest changes to the models."
                        " Make sure 'main.dart --apply-migrations' is run on the next restart."),
                ),
                DefaultButton(
                    onPressed: () async {
                        _isLoading = true;
                        await _commandRunner.serverpodCreateMigration();
                        _isLoading = false;
                    },
                    text: CommandRunner.serverpodCreateMigrationCommand,
                    isLoading: _isLoading,
                ),
                const SizedBox(width: 10),
                DefaultButton(
                    onPressed: () => showCreateMigrationForceWarning(context),
                    text: '--force (WARNING)',
                    isLoading: _isLoading,
                ),
                IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showInfoPopup(
                        CommandRunner.serverpodCreateMigrationCommand,
                        createMigrationHtml,
                    ),
                ),
            ]);
    }

    ///
    /// Shows a warning on 'create-migration --force'
    ///
    void showCreateMigrationForceWarning(BuildContext context) {
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
    Widget _buildServerpodBuildRunnerButton() {
        return Row(children: [
                const Expanded(
                    child: SelectableText("Build server deployment, it will also update generated mock tests"),
                ),
                DefaultButton(
                    onPressed: () async {
                        _isLoading = true;
                        await _commandRunner.buildRunner();
                        _isLoading = false;
                    },
                    text: CommandRunner.buildRunnerCommand,
                    isLoading: _isLoading,
                ),
                const SizedBox(width: 10),
                DefaultButton(
                    onPressed: () async {
                        _isLoading = true;
                        await _commandRunner.buildRunner('--release');
                        _isLoading = false;
                    },
                    text: '--release',
                    isLoading: _isLoading,
                ),
                IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showInfoPopup(
                        CommandRunner.buildRunnerCommand,
                        buildRunnerHtml,
                    ),
                ),
            ]);
    }

    ///
    /// Build the repair migration row
    ///
    Row _buildCreateRepairMigrationButton() {
        return Row(
            children: [
                const Expanded(
                    child: SelectableText("Repair the db schema from the model yaml"),
                ),
                DefaultButton(
                    onPressed: () async {
                        _isLoading = true;
                        await _commandRunner.serverpodCreateRepairMigration();
                        _isLoading = false;
                    },
                    text: serverpodCreateRepairMigrationTitle,
                    isLoading: _isLoading,
                ),
                const SizedBox(width: 10),
                DefaultButton(
                    onPressed: () async {
                        _isLoading = true;
                        await _commandRunner.serverpodApplyRepairMigration();
                        _isLoading = false;
                    },
                    text: serverpodApplyRepairMigrationTitle,
                    isLoading: _isLoading,
                ),
                IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showInfoPopup(
                        serverpodCreateRepairMigrationTitle,
                        serverpodCreateRepairMigrationHtml,
                    ),
                ),
            ],
        );
    }

    ///
    /// Build clean button
    ///
    /// Cleans the library files in all project folders.
    ///
    Row _buildFlutterCleanButton() {
        return Row(
            children: [
                const Expanded(
                    child: SelectableText("Cleans the library files in all project folders. "),
                ),
                DefaultButton(
                    onPressed: () async {
                        _isLoading = true;
                        await _commandRunner.flutterClean();
                        _isLoading = false;
                    },
                    text: flutterCleanTitle,
                    isLoading: _isLoading,
                ),
                IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showInfoPopup(
                        flutterCleanTitle,
                        flutterCleanHtml,
                    ),
                ),
            ],
        );
    }

    ///
    /// Build  flutter get pub
    ///
    Row _buildFlutterGetPubButton() {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                const Expanded(
                    child: SelectableText("Get the latest/upgraded libraries across all 4 project folders. "),
                ),
                DefaultButton(
                    onPressed: () async {
                        _isLoading = true;
                        await _commandRunner.flutterGet();
                        _isLoading = false;
                    },
                    text: flutterGetTitle,
                    isLoading: _isLoading,
                ),
                IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showInfoPopup(
                        flutterGetTitle,
                        flutterGetHtml,
                    ),
                ),
            ],
        );
    }

    ///
    /// Fix the dart_format plugin for intellij
    ///
    _buildFixDartFormatterButton() {
        return Row(
            children: [
                const Expanded(
                    child: SelectableText("Fix dart_format plugin for intellij."),
                ),
                DefaultButton(
                    onPressed: () async {
                        _isLoading = true;
                        await _commandRunner.runFixDartFormat();
                        _isLoading = false;
                    },
                    text: CommandRunner.fixDartFormat,
                    isLoading: _isLoading,
                ),
                IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showInfoPopup(
                        CommandRunner.fixDartFormat,
                        fixDartFormatHtml,
                    ),
                ),
            ],
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


    ///
    /// Shows the info popup
    ///
    void _showInfoPopup(String title, String content) {
        InfoPopupBox(
            context,
            title: title,
            htmlContent: content,
        ).show(context);
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
}
