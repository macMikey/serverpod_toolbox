// app text

String flutterCleanTitle='flutter clean';
String flutterCleanHtml="Runs a clean on all project folders to remove all downloaded packages.  Run 'dart pub get' to download them again";

String fixDartFormatHtml="Installs the dart_format plugin for all projects";

String flutterUpgradeHtml='Upgrades all the pubspec.yaml packages to the latest major versions';

String upgradeCliText='upgrade serverpod_cli';
String upgradeCliHtml='Upgrades the serverpod command line interface';

String flutterGetTitle='dart pub get';
String flutterGetHtml='Runs dart pub get on all project folders, downloading latest package versions';

String createMigrationHtml = """
  <h1>`serverpod create-migration` Command</h1>
  <p>The `serverpod create-migration` command is used in the Serverpod framework to generate a new migration file for your database schema.</p>
  <h2>WARNING: Using the --force command will drop and rebuild any tables that can't be upgraded</h2>
  <h2>Purpose</h2>
  <p>It helps you keep your database schema in sync with your code by automatically generating migration files that update the database structure. These migrations allow you to gradually evolve your database schema without losing data when your application code changes.</p>

  <h2>How It Works</h2>
  <h3>Reads Current Schema</h3>
  <p>When you run `serverpod create-migration`, Serverpod analyzes your existing project setup. It typically reads information from the last applied migration file or, if there isn't one, it assumes an initial database state.</p>
  <h3>Compares with Project Code</h3>
  <p>It then compares this information with the current state of your data models defined in your project's YAML files.</p>
  <h3>Generates Migration</h3>
  <p>Based on the differences between the existing schema and the models defined in your code, Serverpod creates a new migration file. This file contains SQL statements that bring the database schema up to date with your latest data models.</p>
""";



String buildRunnerHtml = """<h2>Building a Flutter App for Production</h2>

<p>The command `dart run build_runner build --release` is used in Flutter development to prepare your application for deployment on app stores. Let's break down each part of the command to understand its functionality:</p>

<ol>
  <li><strong>dart run:</strong> This instructs the computer to execute a Dart script using the `dart` executable.</li>
  <li><strong>build_runner:</strong> This refers to a package in the Flutter ecosystem that provides tools for processing and generating code during the build process.</li>
  <li><strong>build:</strong> This is a specific command provided by the `build_runner` package. It tells the package to perform a build operation on your project.</li>
  <li><strong>--release:</strong> This is an optional flag that instructs `build_runner` to generate a release build of your application. A release build is typically optimized for performance and size, making it suitable for app store deployment.</li>
</ol>

<p><strong>In summary:</strong></p>

<p>This command leverages the `build_runner` package to build your Flutter application for production purposes. The `--release` flag ensures the build is optimized for performance and size.</p>

<p><strong>Additional Notes:</strong></p>

<ul>
  <li>Ensure the `build_runner` package is installed in your project's `pubspec.yaml` file.</li>
  <li>The specific behavior of the `build` command might vary depending on additional configurations or custom builders defined in your project.</li>
</ul>

""";


String serverpodGenerateTitle='serverpod generate ';
String serverpodGenerateHtml = "<b>serverpod generate</b>"
    "<p>Serverpod offers functionalities to automatically generate code based on your server-side definitions, simplifying development.</p>"
    "<b>Model Code Generation</b>"
    "<p>When you define data models with specific fields in YAML files within the lib/src/models directory of your Serverpod project, running `serverpod generate` creates corresponding Dart classes for those models.</p>"
    "<p>These generated classes represent the structure of your data models and provide functionality for interacting with them in your server-side code.</p>"
    "<b>Client Code Generation (Optional)</b>"
    "<p>Serverpod also offers optional client-side code generation.</p>"
    "<p>If you place methods within classes extending the `Endpoint` class in the lib/src/endpoints directory, running `serverpod generate` creates corresponding methods in your Flutter application's client code.</p>"
    "These generated client methods allow you to call the server-side methods defined in your endpoints from your Flutter app seamlessly.";


String serverpodCreateRepairMigrationTitle = "serverpod create-repair-migration";
String serverpodCreateRepairMigrationHtml = "The repair migration system will create a repair migration that makes your database "
    "schema match the newly created migration. To enable the command to fetch your database schema it requires a running server. "
    "Navigate to your project's server package directory and start the server, "
    "then run the create-repair-migration command.  This will also need to be applied to your live database, possibly by manually running the --apply-repair-migration, when deployed";

String serverpodApplyRepairMigrationTitle = "--apply-repair-migration";