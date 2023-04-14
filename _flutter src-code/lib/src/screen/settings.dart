import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/student_dashboard.controller.dart';
import 'package:samids_web_app/src/screen/page_not_found.dart';
import 'package:samids_web_app/src/widgets/student_info_card.dart';

import '../model/student_model.dart';
import '../widgets/mobile_view.dart';

class SettingsPage extends StatelessWidget {
  static const routeName = '/settings';
  final StudentDashboardController sdController;
  const SettingsPage({
    Key? key,
    required this.sdController,
  }) : super(key: key);

  Widget _buildUserInformation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StudentInfoCard(
        student: sdController.student,
      ),
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
          ListTile(
            leading:
                Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
            title: Text('Logout', style: Theme.of(context).textTheme.subtitle1),
            onTap: () {
              // Implement the logout functionality here
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
      if (constraints.maxWidth <= 450) {
        return MobileView(
          showBottomNavBar: false,
          appBarOnly: true,
          currentIndex: 1, // Assuming settings page has index 3
          appBarTitle: "Settings",
          userName: "",
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInformation(context),
                _buildSettingsList(context),
              ],
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Settings"),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
