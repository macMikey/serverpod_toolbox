import 'package:shared_preferences/shared_preferences.dart';

///
/// Stored preferences
///
class Preferences {

    Future<String?> loadProjectDir() async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('projectDir');
    }

    Future<void> saveProjectDir(String dir) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('projectDir', dir);
    }
}