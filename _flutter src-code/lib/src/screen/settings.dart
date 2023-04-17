import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:samids_web_app/src/controllers/data_controller.dart';
import 'package:samids_web_app/src/screen/page_not_found.dart';
import 'package:samids_web_app/src/widgets/student_info_card.dart';

import '../auth/login.dart';
import '../controllers/auth.controller.dart';
import '../model/student_model.dart';
import '../settings/settings_controller.dart';
import '../widgets/mobile_view.dart';
import '../widgets/web_view.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';
  final DataController sdController;
  final DataController studentDashboardController = DataController.instance;
  final AuthController authController = AuthController.instance;

  final SettingsController settingsController;
  SettingsPage({
    Key? key,
    required this.sdController,
    required this.settingsController,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  DataController get _sdController => widget.studentDashboardController;

  AuthController get _authController => widget.authController;
  SettingsController get settingsController => widget.settingsController;
  Widget _buildUserInformation(BuildContext context) {
    return StudentInfoCard(
      user: widget.sdController.student,
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.lock, color: Theme.of(context).iconTheme.color),
            title: Text('Change Password',
                style: Theme.of(context).textTheme.subtitle1),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    title: Text('Change Password',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    content: Text(
                        'An email has been sent to your registered email address with instructions on how to change your password.',
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText1!.color)),
                    actions: [
                      TextButton(
                        child: Text('Close',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Visibility(
            visible: MediaQuery.of(context).size.width <= 450,
            child: ListTile(
              leading:
                  Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
              title:
                  Text('Logout', style: Theme.of(context).textTheme.subtitle1),
              onTap: () {
                _authController.logout();
                _sdController.dispose();
                GetIt.instance.unregister<DataController>();

                Navigator.of(context).pushNamedAndRemoveUntil(
                    LoginScreen.routeName, (Route<dynamic> route) => false);
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6,
                color: Theme.of(context).iconTheme.color),
            title: Text('Theme', style: Theme.of(context).textTheme.subtitle1),
            trailing: DropdownButton<ThemeMode>(
              value: settingsController.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  settingsController.updateThemeMode(newValue);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth <= 450) {
        return MobileView(
            showBottomNavBar: true,
            appBarOnly: true,
            currentIndex: 3, // Assuming settings page has index 1
            appBarTitle: "Settings",
            userName: "",
            body: [
              _buildUserInformation(context),
              _buildSettingsList(context),
            ]);
      } else {
        return WebView(
          appBarTitle: "Settings",
          selectedWidgetMarker: 2, // Assuming settings page has index 1
          body: SingleChildScrollView(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildUserInformation(context),
                _buildSettingsList(context),
              ],
            ),
          ),
        );
      }
    });
  }
}
