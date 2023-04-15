// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:samids_web_app/src/auth/login.dart';
import 'package:samids_web_app/src/controllers/student_dashboard.controller.dart';

import 'package:samids_web_app/src/screen/page_not_found.dart';
import 'package:samids_web_app/src/screen/settings.dart';
import 'package:samids_web_app/src/screen/student/attendance.dart';
import 'package:samids_web_app/src/screen/student/classes.dart';
import 'package:samids_web_app/src/screen/student/dashboard.dart';
import 'package:samids_web_app/src/settings/settings_controller.dart';
import 'package:google_fonts/google_fonts.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  final radius = 10.0;
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
          // theme: ThemeData(
          //   bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          //     backgroundColor: const Color(0xFFF5F6F9),
          //     selectedItemColor: Colors.black,
          //     // unselectedItemColor: Colors.grey[400],
          //     elevation: 0.0,
          //   ),
          //   appBarTheme: ThemeData().appBarTheme.copyWith(
          //         color: const Color(0xFFF5F6F9),
          //         iconTheme: const IconThemeData(
          //           color: Colors.black,
          //         ),
          //         titleTextStyle: const TextStyle(
          //           color: Colors.black,
          //           fontSize: 20,
          //           fontWeight: FontWeight.bold,
          //         ),
          //         elevation: 0.1,
          //       ),
          //   scaffoldBackgroundColor: const Color(0xFFF5F6F9),
          //   cardTheme: const CardTheme(
          //     margin: EdgeInsets.all(6),
          //     elevation: 0.2,
          //   ),
          //   fontFamily: GoogleFonts.inter().fontFamily,
          //   textTheme: const TextTheme(
          //     titleLarge: TextStyle(
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          // darkTheme: ThemeData.dark(),
          theme: ThemeData(
            cardTheme: CardTheme(
              margin: EdgeInsets.only(left: 6, right: 6, bottom: 6),
              elevation: 0.2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    radius), // set circular border radius for Cards
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(radius),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F6F9),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            appBarTheme: AppBarTheme(
              toolbarHeight: 80,
              color: const Color(0xFFF5F6F9),
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              elevation: 0.1,
            ),
            drawerTheme: DrawerThemeData(
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius),
                  bottomLeft: Radius.circular(radius),
                ),
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedItemColor: Theme.of(context).primaryColor,
              elevation: 0.0,
            ),

            dividerColor: Theme.of(context)
                .scaffoldBackgroundColor, // Set divider color to match scaffold color
            dataTableTheme: DataTableThemeData(
              dividerThickness: 2.0,
              headingTextStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold, // Set header font weight to bold
                fontStyle: FontStyle.normal, // Set header font style to normal
              ),
            ),
            fontFamily: GoogleFonts.inter().fontFamily,
            textTheme: ThemeData.light().textTheme.copyWith(
                  titleLarge: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D0D0D),
                  ),
                ),
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
                .copyWith(background: const Color(0xFFF5F6F9))
                .copyWith(secondary: Color.fromARGB(255, 0, 0, 0)),
          ),

          themeMode: settingsController.themeMode,
          initialRoute: LoginScreen.routeName,
          home: LoginScreen(),

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case StudentDashboard.routeName:
                return MaterialPageRoute(builder: (_) => StudentDashboard());
              case StudentAttendance.routeName:
                return MaterialPageRoute(
                    builder: (_) => StudentAttendance(
                          sdController: StudentDashboardController.instance,
                        ));
              case SettingsPage.routeName:
                return MaterialPageRoute(
                    builder: (_) => SettingsPage(
                          sdController: StudentDashboardController.instance,
                        ));
              case LoginScreen.routeName:
                return MaterialPageRoute(builder: (_) => LoginScreen());
              case StudentClasses.routeName:
                return MaterialPageRoute(
                    builder: (_) => StudentClasses(
                          sdController: StudentDashboardController.instance,
                        ));
              default:
                return MaterialPageRoute(builder: (_) => const PageNotFound());
            }
          },
        );
      },
    );
  }
}
