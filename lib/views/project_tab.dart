import 'dart:async';

import 'package:flutter/material.dart';
import 'package:serverpod_toolbox/controllers/project_tab_controller.dart';
import 'package:serverpod_toolbox/widgets/command_row.dart';
import 'package:serverpod_toolbox/widgets/default_button.dart';

import '../controllers/command_runner.dart';
import '../en.dart';

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

    late ProjectTabController _controller;
    final TextEditingController _popupLogController = TextEditingController();
    final _popupLogAreaScrollController = ScrollController();
    final TextEditingController _integratedLogController = TextEditingController();
    final _integratedLogAreaScrollController = ScrollController();
    bool _isLoading = false;
    late Future<void> _loadPreferencesFuture;

    @override
    void initState() {
        super.initState();

        _popupLogController.addListener(() {
                // Scroll to the bottom whenever new text is added
                _popupLogAreaScrollController.jumpTo(_popupLogAreaScrollController.position.maxScrollExtent);
            });
        _integratedLogController.addListener(() {
                // Scroll to the bottom whenever new text is added
                _integratedLogAreaScrollController.jumpTo(_integratedLogAreaScrollController.position.maxScrollExtent);
            });
        _controller = ProjectTabController(_popupLogController);
        _loadPreferencesFuture = _controller.loadPreferences();
        setState(() {});
    }

    @override
    Widget build(BuildContext context) {
        return FutureBuilder<void>(
            future: _loadPreferencesFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while waiting for the future to complete
                    return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                    // Handle errors
                    return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                    // Future completed successfully, build form
                    return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                            children: [
                                const SizedBox(height: 20),
                                _buildProjectFolderSelector(),
                                Expanded(
                                    child: SingleChildScrollView(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                                const SizedBox(height: 20),
                                                Text("Serverpod Commands", style: Theme.of(context).textTheme.headlineSmall),
                                                Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                                                    padding: const EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey),
                                                        borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: Column(
                                                        children: [
                                                            _buildUpgradeCLIRow(),
                                                            buildDivider(),
                                                            _buildServerpodGenerateRow(),
                                                            buildDivider(),
                                                            _buildServerpodCreateMigrationRow(),
                                                            buildDivider(),
                                                            _buildServerpodBuildRunnerRow(),
                                                            buildDivider(),
                                                            _buildCreateRepairMigrationRow(),
                                                        ],
                                                    ),
                                                ),
                                                Text("Flutter Commands", style: Theme.of(context).textTheme.headlineSmall),
                                                Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                                                    padding: const EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey),
                                                        borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: Column(
                                                        children: [
                                                            _buildFlutterUpgradeRow(),
                                                            buildDivider(),
                                                            _buildFlutterCleanRow(),
                                                            buildDivider(),
                                                            _buildFlutterGetPubRow(),
                                                            buildDivider(),
                                                            _buildFixDartFormatterRow(),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
                                _buildClearLogButton(),
                                _buildLogOutputArea(),
                                IconButton(
                                    icon: const Icon(Icons.open_in_new),
                                    onPressed: _showLogAreaPopup,
                                ),
                            ],
                        ),
                    );
                }
            });
    }

    ///
    /// Build the project folder text field and folder selector button
    ///
    SizedBox _buildProjectFolderSelector() {
        return SizedBox(
            width: 1200,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                    Flexible(
                        flex: 3,
                        child: TextField(
                            controller: TextEditingController(text: _controller.projectFolderPath),
                            decoration: const InputDecoration(
                                labelText: 'Select Top Level Project folder',
                                border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                                _controller.updateProjectFolder(value);
                            },
                        ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                        flex: 1,  // Adjust the flex to make sure the button gets enough space
                        child: DefaultButton(
                            onPressed: () => _controller.handleProjectFolderSelector(context, setState),
                            text: '...',
                            isLoading: _isLoading,
                        ),
                    ),
                ],
            ),
        );
    }

    ///
    /// Build the flutter upgrade button
    ///
    CommandRow _buildFlutterUpgradeRow() {
        return CommandRow(
            context: context,
            label: "Upgrade flutter version, you can use --force if there are major changes.",
            commandText: CommandRunner.flutterPubUpgrade,
            onPlayPressed: () async {
                _setLoading(true);
                _controller.commandRunner.flutterUpgrade();
                _setLoading(false);
            },
            infoHtmlBody: flutterUpgradeHtml,
            isLoading: _isLoading,
        );
    }

    ///
    /// Build the 'upgrade CLI version' row
    ///
    CommandRow _buildUpgradeCLIRow() {
        return CommandRow(
            context: context,
            label: "Upgrade serverpod CLI version, required if upgrading flutter.   ",
            commandText: upgradeCliText,
            onPlayPressed: () async {
                _setLoading(true);
                _controller.commandRunner.runUpgradeCLI();
                _setLoading(false);
            },
            infoHtmlBody: upgradeCliHtml,
            isLoading: _isLoading,
        );
    }

    ///
    /// Build the 'serverpod generate' row
    ///
    CommandRow _buildServerpodGenerateRow() {
        return CommandRow(
            context: context,
            label: "Generate model (model db classes) and end point code.\nNote: Run 'serverpod create-migration' (below) for any DB changes",
            commandText: serverpodGenerateTitle,
            onPlayPressed: () async {
                _setLoading(true);
                await _controller.commandRunner.serverPodGenerate();
                _setLoading(false);
            },
            infoHtmlBody: serverpodGenerateHtml,
            isLoading: _isLoading,
        );
    }

    ///
    /// Build the 'create migration' row, with a secondary --force create migration button
    ///
    CommandRow _buildServerpodCreateMigrationRow() {
        return CommandRow(
            context: context,
            label: "Create an upgrade script for your db with the latest changes to the models.\n"
            "Make sure 'main.dart --apply-migrations' is run on the next restart.",
            commandText: CommandRunner.serverpodCreateMigrationCommand,
            onPlayPressed: () async {
                _setLoading(true);
                await _controller.commandRunner.serverpodCreateMigration();
                _setLoading(false);
            },
            infoHtmlBody: createMigrationHtml,
            isLoading: _isLoading,
            secondaryCommandText: '${CommandRunner.serverpodCreateMigrationCommand} --force (WARNING)',
            onSecondaryPlayPressed: () async {
                _setLoading(true);
                _showMigrationForceWarning(context);
                _setLoading(false);
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
                            _controller.commandRunner.serverpodCreateMigration('--force');
                        },
                        child: const Text('Continue'),
                    ),
                ],
            ));
    }

    ///
    /// Build the 'dart run build_runner build --release' button
    ///
    CommandRow _buildServerpodBuildRunnerRow() {
        return CommandRow(
            context: context,
            label: "Build server deployment, it will also update generated mock tests",
            commandText: CommandRunner.buildRunnerCommand,
            onPlayPressed: () async {
                _setLoading(true);
                await _controller.commandRunner.buildRunner();
                _setLoading(false);
            },
            infoHtmlBody: buildRunnerHtml,
            isLoading: _isLoading,
            secondaryCommandText: '${CommandRunner.buildRunnerCommand} --release',
            onSecondaryPlayPressed: () async {
                _setLoading(true);
                await _controller.commandRunner.buildRunner('--release');
                _setLoading(false);
            },
        );
    }

    ///
    /// Build the repair migration row
    ///
    CommandRow _buildCreateRepairMigrationRow() {
        return CommandRow(
            context: context,
            label: "Create a repair script of the db schema using the model yaml.\n"
            "This will need to be applied on the next server run, or by using the --apply-repair-migration here",
            commandText: serverpodCreateRepairMigrationTitle,
            onPlayPressed: () async {
                _setLoading(true);
                await _controller.commandRunner.serverpodCreateRepairMigration();
                _setLoading(false);
            },
            infoHtmlBody: serverpodCreateRepairMigrationHtml,
            isLoading: _isLoading,
            secondaryCommandText: CommandRunner.serverpodApplyRepairMigrationCommand, //serverpodApplyRepairMigrationTitle,
            onSecondaryPlayPressed: () async {
                _setLoading(true);
                await _controller.commandRunner.serverpodApplyRepairMigration();
                _setLoading(false);
            },
        );
    }

    ///
    /// Build clean button
    ///
    /// Cleans the library files in all project folders.
    ///
    CommandRow _buildFlutterCleanRow() {
        return CommandRow(
            context: context,
            label: "Cleans the library files in all project folders.",
            commandText: flutterCleanTitle,
            onPlayPressed: () async {
                _setLoading(true);
                await _controller.commandRunner.flutterClean();
                _setLoading(false);
            },
            infoHtmlBody: flutterCleanHtml,
            isLoading: _isLoading,
        );
    }

    ///
    /// Build 'flutter get pub'
    ///
    CommandRow _buildFlutterGetPubRow() {
        return CommandRow(
            context: context,
            label: "Get the latest/upgraded libraries across all 4 project folders.",
            commandText: flutterGetTitle,
            onPlayPressed: () async {
                _setLoading(true);
                await _controller.commandRunner.flutterGet();
                _setLoading(false);
            },
            infoHtmlBody: flutterGetHtml,
            isLoading: _isLoading,
        );
    }

    ///
    /// Fix the dart_format plugin for intellij
    ///
    CommandRow _buildFixDartFormatterRow() {
        return CommandRow(
            context: context,
            label: "Fix dart_format plugin for IntelliJ.",
            commandText: CommandRunner.fixDartFormat,
            onPlayPressed: () async {
                _setLoading(true);
                await _controller.commandRunner.runFixDartFormat();
                _setLoading(false);
            },
            infoHtmlBody: fixDartFormatHtml,
            isLoading: _isLoading,
        );
    }

    ///
    /// Clear log button
    ///
    Row _buildClearLogButton() {
        return Row(
            children: [
                DefaultButton(
                    onPressed: () {
                        setState(() {
                                _popupLogController.text = ''; // Clear the text controller
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
    Widget _buildLogOutputArea() {
        return SizedBox(
            height: 150,
            child: NotificationListener<ScrollNotification>(
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                    ),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxHeight: 500.0,
                        ),
                        child: ListView(
                            controller: _integratedLogAreaScrollController,
                            children: [
                                TextField(
                                    controller: _integratedLogController,
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
    /// Shows the log area popup
    ///
    void _showLogAreaPopup() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return Dialog(
                    child: SizedBox(
                        width: 1000.0,
                        height: 1400.0,
                        child: Column(
                            children: [
                                AppBar(
                                    title: const Text('Log Output'),
                                    actions: [
                                        IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () {
                                                Navigator.of(context).pop();
                                            },
                                        ),
                                    ],
                                ),
                                Expanded(
                                    child: NotificationListener<ScrollNotification>(
                                        child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                            ),
                                            child: ListView(
                                                controller: _popupLogAreaScrollController,
                                                children: [
                                                    TextField(
                                                        controller: _popupLogController,
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
                            ],
                        ),
                    ),
                );
            },
        );
    }

    @override
    void dispose() {
        _popupLogController.dispose();
        _popupLogAreaScrollController.dispose();
        _integratedLogController.dispose();
        _integratedLogAreaScrollController.dispose();
        super.dispose();
    }

    ///
    /// Divider and spacer
    ///
    Widget buildDivider() {
        return const Column(
            children: [
                Divider(
                    // Add divider line here
                    thickness: 1, // Adjust thickness as needed
                    color: Colors.grey, // Adjust color as needed
                ),
                SizedBox(height: defaultControlSpacing)
            ],
        );
    }

    void _setLoading(bool isLoading) {
        if (isLoading) {
            _popupLogController.text = '';
            _showLogAreaPopup();
        }
        setState(() {
                _isLoading = isLoading;
            });
    }
}
