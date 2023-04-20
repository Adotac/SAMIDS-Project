// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';
import 'package:samids_web_app/src/screen/page_not_found.dart';
import 'package:samids_web_app/src/widgets/student_info_card.dart';
import 'package:flutter/widgets.dart';

import '../auth/login.dart';
import '../controllers/auth.controller.dart';
import '../controllers/faculty_controller.dart';
import '../model/student_model.dart';
import '../settings/settings_controller.dart';
import '../widgets/mobile_view.dart';
import '../widgets/web_view.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  final AuthController authController = AuthController.instance;

  final SettingsController settingsController;
  SettingsPage({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final _sdController;
  @override
  void initState() {
    int userType = _authController.loggedInUser!.type.index;
    switch (userType) {
      case 0:
        _sdController = StudentController.instance;
        break;
      case 1:
        _sdController = FacultyController.instance;
        break;
    }
    super.initState();
  }

  AuthController get _authController => widget.authController;
  SettingsController get settingsController => widget.settingsController;
  Widget _buildUserInformation(BuildContext context) {
    int userType = _authController.loggedInUser!.type.index;
    switch (userType) {
      case 0:
        return StudentInfoCard(
          firstName: _sdController.student.firstName,
          lastName: _sdController.student.lastName,
        );
      case 1:
        return StudentInfoCard(
          firstName: _sdController.faculty.firstName,
          lastName: _sdController.faculty.lastName,
        );
    }
    return StudentInfoCard(
      firstName: _sdController.student.firstName,
      lastName: _sdController.student.lastName,
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
                int userType = _authController.loggedInUser!.type.index;
                switch (userType) {
                  case 0:
                    StudentController.instance.dispose();
                    GetIt.instance.unregister<StudentController>();
                    break;
                  case 1:
                    FacultyController.instance.dispose();
                    GetIt.instance.unregister<FacultyController>();
                    break;
                }

                _authController.logout();

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
