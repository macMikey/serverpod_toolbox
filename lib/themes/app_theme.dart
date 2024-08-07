import 'package:flutter/material.dart';


///
/// The theme for the app.
///
/// Additional themes can be added using the themeOption parameter
///
/// Usage:    final currentTheme = AppTheme.create(themeOption: 'light');
///              MaterialApp(theme: currentTheme.themeData,...)
///
class AppTheme {
    static Color themeColour = Colors.indigo;
    static const double listButtonHeight = 90;
    static const double standardButtonHeight = 30;
    static const double fontStandardSize = 16;
    static const double fontTitleSize = 26;
    static const double navigationRailLabelTextSize = 15;
    late AppBarTheme appBarTheme;
     late NavigationRailThemeData navigationRailThemeData;

     late Brightness brightness;

    // Colour scheme based on brightness (light/dark mode)
     late ColorScheme colorScheme;

    // Text theme with various styles
     late TextTheme textTheme;


    ///
    /// Create an AppTheme instance for the specified theme option
    ///
    AppTheme(BuildContext context, ThemeMode themeMode) {
        switch (themeMode) {
            case ThemeMode.light:
                _lightTheme();
                break;
            case ThemeMode.dark:
                _darkTheme();
                break;
            case ThemeMode.system:
                 MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? _darkTheme() : _lightTheme();
                 break;
            default:
                throw ArgumentError('Invalid theme option: $themeMode');
        }
    }

    ///
    /// The light app theme
    ///
    void _lightTheme() {
        brightness = Brightness.light;
        colorScheme = ColorScheme.fromSeed(
            seedColor: themeColour,
            brightness: Brightness.light,
        ).copyWith(
            background: Colors.white,
        );
        appBarTheme = const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
        );
        navigationRailThemeData = const NavigationRailThemeData(
            backgroundColor: Colors.white,
        );
        textTheme = const TextTheme(
            // ... define light text styles here
            displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        );
    }


    ///
    /// The dark app theme
    ///
    void _darkTheme() {
       brightness = Brightness.dark;
      colorScheme = ColorScheme.fromSeed(
          seedColor: themeColour,
          brightness: Brightness.dark,
      );
      appBarTheme = const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
      );
      navigationRailThemeData = const NavigationRailThemeData(
          backgroundColor: Colors.black,
      );
      textTheme = const TextTheme(
          // ... define dark text styles here
          displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
      );
    }


    ///
    /// Create a ThemeData object based on the current theme settings
    ///
    ThemeData get themeData {
        return ThemeData(
            useMaterial3: true,
            brightness: brightness,
            colorScheme: colorScheme,
            textTheme: textTheme,
            appBarTheme: appBarTheme,
            navigationRailTheme: navigationRailThemeData,
        );
    }


    /// Style for a standard button
    ///
    static ButtonStyle standardButtonStyle({bool greyOut = false}) {
        return ElevatedButton.styleFrom(
            textStyle: const TextStyle( // Add textStyle property
                fontSize: 16.0, // Set desired font size
                fontWeight: FontWeight.normal, // Set desired font weight (bold in this case)
            //    fontFamily: 'your_font_family', // Set desired font family (replace with your font)
            ),
            fixedSize: const Size(double.infinity, AppTheme.standardButtonHeight),
            foregroundColor: Colors.white,
            backgroundColor: greyOut ? Colors.grey[300] : themeColour,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                //  side: const BorderSide(color: Colors.black, width: 1), // Add border color and width
            ),
        );
    }

    ///
    /// Style for a list selection button
    ///
    static ButtonStyle listButtonStyle({bool greyOut = false}) {
        return ElevatedButton.styleFrom(
            fixedSize: const Size(double.infinity, AppTheme.listButtonHeight),
            backgroundColor: greyOut ? Colors.grey[300] : Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
                side: const BorderSide(color: Colors.black, width: 1), // Add border color and width
            ),
        );
    }
}

