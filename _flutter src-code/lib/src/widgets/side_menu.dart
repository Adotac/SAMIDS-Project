import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:samids_web_app/src/auth/login.dart';
import 'package:samids_web_app/src/controllers/auth.controller.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';
import 'package:samids_web_app/src/screen/faculty/attendance.dart';
import 'package:samids_web_app/src/screen/faculty/dashboard.dart';
import 'package:samids_web_app/src/screen/settings.dart';

import '../screen/student/attendance.dart';
import '../screen/student/dashboard.dart';

class SideMenu extends StatefulWidget {
  final AuthController authController = AuthController.instance;
  SideMenu({
    Key? key,
    required this.selectedWidgetMarker,
    // required this.studentDashboardController,
    // required this.authController
  }) : super(key: key);
  int selectedWidgetMarker;
  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int get _selectedIndex => widget.selectedWidgetMarker;

  AuthController get _authController => widget.authController;
  set _selectedIndex(int index) {
    widget.selectedWidgetMarker = index;
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required int index,
    required Function onTap,
  }) {
    return ListTile(
      leading: Icon(icon,
          color:
              _selectedIndex == index ? Theme.of(context).primaryColor : null),
      title: Text(
        title,
        style: TextStyle(
          color:
              _selectedIndex == index ? Theme.of(context).primaryColor : null,
          fontWeight: _selectedIndex == index ? FontWeight.bold : null,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 18.0, bottom: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      width: 250,
      child: Column(
        children: [
          const SizedBox(height: 60),
          _buildListTile(
            icon: Icons.event_note_outlined,
            title: 'Dashboard',
            index: 0,
            onTap: () {
              Navigator.popAndPushNamed(context, FacultyDashboard.routeName);
            },
          ),
          _buildListTile(
            icon: Icons.event_available_outlined,
            title: 'Attendance',
            index: 1,
            onTap: () {
              Navigator.popAndPushNamed(context, FacultyAttendance.routeName);
            },
          ),
          _buildListTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            index: 2,
            onTap: () {
              Navigator.popAndPushNamed(context, SettingsPage.routeName);
            },
          ),
          const Spacer(),
          _buildListTile(
            icon: Icons.logout_outlined,
            title: 'Logout',
            index: 3,
            onTap: () {
              int userType = _authController.loggedInUser!.type.index;
              switch (userType) {
                case 0:
                  StudentController.instance.dispose();
                  break;
                case 1:
                  FacultyController.instance.dispose();
                  break;
              }

              _authController.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  LoginScreen.routeName, (Route<dynamic> route) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
