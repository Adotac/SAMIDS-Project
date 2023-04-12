import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:samids_web_app/src/auth/login.dart';

import 'package:samids_web_app/src/screen/my_app.dart';
import 'package:samids_web_app/src/screen/student/dashboard.dart';
import 'package:samids_web_app/src/settings/settings_controller.dart';
import 'package:google_fonts/google_fonts.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: const Color(0xFFF5F6F9),
              selectedItemColor: Colors.black,
              // unselectedItemColor: Colors.grey[400],
              elevation: 0.0,
            ),
            appBarTheme: ThemeData().appBarTheme.copyWith(
                  color: const Color(0xFFF5F6F9),
                  iconTheme: const IconThemeData(
                    color: Colors.black,
                  ),
                  titleTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 0.1,
                ),
            scaffoldBackgroundColor: const Color(0xFFF5F6F9),
            cardTheme: const CardTheme(
              margin: EdgeInsets.all(6),
              elevation: 0.2,
            ),
            fontFamily: GoogleFonts.inter().fontFamily,
            textTheme: const TextTheme(
              titleLarge: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          initialRoute: LoginScreen.routeName,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            print(routeSettings.name);
            switch (routeSettings.name) {
              case StudentDashboard.routeName:
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => StudentDashboard(),
                );
              case LoginScreen.routeName:
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => LoginScreen(),
                );
              default:
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => const Text('Not Found'),
                );
            }
          },
        );
      },
    );
  }
}
