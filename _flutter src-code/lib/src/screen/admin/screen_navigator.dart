import 'package:flutter/material.dart';
import 'package:samids_web_app/src/screen/admin/dashboard.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../constant/constant_values.dart';

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
        switch (controller.selectedIndex) {
          case 0:
            return AdminDashboard(
              pageTitle: pageTitle,
            );
          default:
            return Text(
              pageTitle,
              style: theme.textTheme.headlineSmall,
            );
        }
      },
    );
  }
}
