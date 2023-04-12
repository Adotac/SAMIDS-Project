// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:samids_web_app/src/screen/page_not_found.dart';
// import 'package:samids_web_app/src/settings/settings_controller.dart';

// import 'student/attendance.dart';
// import 'student/dashboard.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({
//     Key? key,
//     required this.settingsController,
//   }) : super(key: key);

//   final SettingsController settingsController;

//   Route<dynamic>? generateRoutes(RouteSettings settings) {
//     print(settings.name);
//     switch (settings.name) {
//       case StudentDashboard.routeName:
//         return MaterialPageRoute(builder: (_) => const StudentDashboard());
//       case StudentAttendance.routeName:
//         return MaterialPageRoute(builder: (_) => StudentAttendance());
//       default:
//         print('settings.name page not found = ${settings.name}');
//         return MaterialPageRoute(builder: (_) => const PageNotFound());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: settingsController,
//       builder: (BuildContext context, Widget? child) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           restorationScopeId: 'app',
//           localizationsDelegates: const [
//             GlobalMaterialLocalizations.delegate,
//             GlobalWidgetsLocalizations.delegate,
//             GlobalCupertinoLocalizations.delegate,
//           ],
//           supportedLocales: const [
//             Locale('en', ''), // English, no country code
//           ],
//           theme: ThemeData(
//             bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//               backgroundColor: Color(0xFFF5F6F9),
//               selectedItemColor: Colors.black,
//               elevation: 0.0,
//             ),
//             appBarTheme: ThemeData().appBarTheme.copyWith(
//                   color: const Color(0xFFF5F6F9),
//                   iconTheme: const IconThemeData(
//                     color: Colors.black,
//                   ),
//                   titleTextStyle: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   elevation: 0.1,
//                 ),
//             scaffoldBackgroundColor: const Color(0xFFF5F6F9),
//             cardTheme: const CardTheme(
//               margin: EdgeInsets.all(6),
//               elevation: 0.2,
//             ),
//             fontFamily: GoogleFonts.inter().fontFamily,
//             textTheme: const TextTheme(
//               titleLarge: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           themeMode: settingsController.themeMode,
//           onGenerateRoute: generateRoutes,
//         );
//       },
//     );
//   }
// }
