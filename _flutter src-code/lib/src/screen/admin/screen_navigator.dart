import 'package:flutter/material.dart';
import 'package:samids_web_app/src/screen/admin/attendance.dart';
import 'package:samids_web_app/src/screen/admin/dashboard.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../constant/constant_values.dart';
import '../student/dashboard.dart';

class ScreenNavigator extends StatelessWidget {
  const ScreenNavigator({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pageTitle = getTitleByIndex(controller.selectedIndex);
        return studentPageNavigator(pageTitle, theme);
      },
    );
  }

  StatelessWidget adminPageNavigator(String pageTitle, ThemeData theme) {
    switch (controller.selectedIndex) {
      case 0:
        return AdminDashboard();
      case 1:
        return AdminAttendance();
      default:
        return Text(
          pageTitle,
          style: theme.textTheme.headlineSmall,
        );
    }
  }

  StatelessWidget studentPageNavigator(String pageTitle, ThemeData theme) {
    switch (controller.selectedIndex) {
      case 0:
        return StudentDashboard();
      case 1:
        return AdminAttendance();
      default:
        return Text(
          pageTitle,
          style: theme.textTheme.headlineSmall,
        );
    }
  }
}
