import 'package:flutter/material.dart';
import 'package:samids_web_app/src/screen/page_not_found.dart';
import 'package:samids_web_app/src/widgets/student_info_card.dart';

import '../widgets/mobile_view.dart';

class SettingsPage extends StatelessWidget {
  static const routeName = '/settings';

  SettingsPage({Key? key}) : super(key: key);

  Widget _buildUserInformation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StudentInfoCard(),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Change Password'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Change Password'),
                    content: const Text(
                        'An email has been sent to your registered email address with instructions on how to change your password.'),
                    actions: [
                      TextButton(
                        child: const Text('Close'),
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
            leading: Icon(Icons.logout),
            title: Text('Logout'),
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
