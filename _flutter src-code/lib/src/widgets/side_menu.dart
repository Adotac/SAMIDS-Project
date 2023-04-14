import 'package:flutter/material.dart';
import 'package:samids_web_app/src/screen/settings.dart';

import '../screen/student/attendance.dart';
import '../screen/student/dashboard.dart';

class SideMenu extends StatefulWidget {
  SideMenu({Key? key, required this.selectedWidgetMarker}) : super(key: key);
  int selectedWidgetMarker;
  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int get _selectedIndex => widget.selectedWidgetMarker;

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
      leading: Icon(icon, color: _selectedIndex == index ? Colors.black : null),
      title: Text(
        title,
        style: TextStyle(
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
      margin: EdgeInsets.only(left: 18.0, bottom: 18),
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
              Navigator.popAndPushNamed(context, StudentDashboard.routeName);
            },
          ),
          _buildListTile(
            icon: Icons.event_available_outlined,
            title: 'Attendance',
            index: 1,
            onTap: () {
              Navigator.popAndPushNamed(context, StudentAttendance.routeName);
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
          Spacer(),
          _buildListTile(
            icon: Icons.logout_outlined,
            title: 'Logout',
            index: 3,
            onTap: () {
              // Perform Logout action and navigate to Login Page
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
