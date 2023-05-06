import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:samids_web_app/src/auth/login.dart';
import 'package:samids_web_app/src/controllers/admin_controller.dart';
import 'package:samids_web_app/src/controllers/auth.controller.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';
import 'package:samids_web_app/src/screen/admin/attendance.dart';
import 'package:samids_web_app/src/screen/admin/dashboard.dart';
import 'package:samids_web_app/src/screen/admin/manage_faculty.dart';
import 'package:samids_web_app/src/screen/admin/manage_student.dart';
import 'package:samids_web_app/src/screen/admin/manage_subjects.dart';
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
  // ignore: library_private_types_in_public_api
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
              int userType = _authController.loggedInUser?.type.index ?? -1;
              switch (userType) {
                case 0:
                  Navigator.popAndPushNamed(
                      context, StudentDashboard.routeName);
                  break;
                case 1:
                  Navigator.popAndPushNamed(
                      context, FacultyDashboard.routeName);
                  break;
                default:
                  Navigator.popAndPushNamed(
                    context,
                    AdminDashboard.routeName,
                  );
              }
            },
          ),
          _buildListTile(
            icon: Icons.event_available_outlined,
            title: 'Attendance',
            index: 1,
            onTap: () {
              int userType = _authController.loggedInUser?.type.index ?? -1;
              switch (userType) {
                case 0:
                  Navigator.popAndPushNamed(
                      context, StudentAttendance.routeName);
                  break;
                case 1:
                  Navigator.popAndPushNamed(
                      context, FacultyAttendance.routeName);
                  break;

                default:
                  Navigator.popAndPushNamed(
                    context,
                    AdminAttendance.routeName,
                  );
              }
            },
          ),
          Visibility(
            visible: _authController.loggedInUser == null,
            child: _buildListTile(
              icon: Icons.group_outlined,
              title: 'Students',
              index: 2,
              onTap: () {
                Navigator.popAndPushNamed(context, ManageStudent.routeName);
              },
            ),
          ),
          Visibility(
            visible: _authController.loggedInUser == null,
            child: _buildListTile(
              icon: Icons.book_outlined,
              title: 'Faculty',
              index: 3,
              onTap: () {
                Navigator.popAndPushNamed(context, ManageFaculty.routeName);
              },
            ),
          ),
          Visibility(
            visible: _authController.loggedInUser == null,
            child: _buildListTile(
              icon: Icons.school_outlined,
              title: 'Subjects',
              index: 4,
              onTap: () {
                Navigator.popAndPushNamed(context, ManageSubjects.routeName);
              },
            ),
          ),
          Visibility(
            visible: _authController.loggedInUser != null,
            child: _buildListTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              index: 2,
              onTap: () {
                Navigator.popAndPushNamed(context, SettingsPage.routeName);
              },
            ),
          ),
          const Spacer(),
          _buildListTile(
            icon: Icons.logout_outlined,
            title: 'Logout',
            index: 3,
            onTap: () {
              int userType = _authController.loggedInUser?.type.index ?? -1;
              switch (userType) {
                case 0:
                  StudentController.instance.dispose();
                  GetIt.instance.unregister<StudentController>();
                  break;
                case 1:
                  FacultyController.instance.dispose();
                  GetIt.instance.unregister<FacultyController>();
                  break;
                default:
                  AdminController.instance.dispose();
                  GetIt.instance.unregister<AdminController>();
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
