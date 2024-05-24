
import 'package:flutter/material.dart';
import 'package:serverpod_toolbox/project_tab.dart';
import 'package:serverpod_toolbox/themes/app_theme.dart';
import 'package:serverpod_toolbox/user_admin_tab.dart';


///
/// A toolbox for common commands used when developing a serverpod project
///
class ServerPodToolbox extends StatefulWidget {
    const ServerPodToolbox({super.key});

    @override
    ServerPodToolboxState createState() => ServerPodToolboxState();
}

class ServerPodToolboxState extends State<ServerPodToolbox> {

    @override
    Widget build(BuildContext context) {
        final currentTheme = AppTheme('light'); // Change to 'light' or 'dark'
        return MaterialApp(
            title: "Serverpod Toolbox",
            theme: currentTheme.themeData,
            home: DefaultTabController(
                length: 2, // Define the number of tabs (2 in this case)
                child: Scaffold(
                    appBar: AppBar(
                        title: const Text('Serverpod Toolbox - A set of tools for managing a serverpod project'),
                        bottom: const TabBar(
                            tabs: [
                                Tab(text: 'Project'),
                                Tab(text: 'User Admin- TBA'),
                            ],
                        ),
                    ),
                    body: const TabBarView(
                        children: [
                            ProjectTab(),
                            UserAdminTab(),
                        ],
                    ),
                ),
            ),
        );
    }
}

void main() {
    runApp(const MaterialApp(
            home: ServerPodToolbox(),
        ));
}
