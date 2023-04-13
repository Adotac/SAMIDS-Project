import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/auth.controller.dart';
import 'package:samids_web_app/src/controllers/student_dashboard.controller.dart';

import 'src/api/api_controller.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import './app.dart';

void main() async {
  // ApiController apiController = ApiController();
  // var future = await apiController.get("Student");
  // print(future);

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();
  AuthController.initialize();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));
}
