// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../constant/constant_values.dart';

class SideBarX extends StatelessWidget {
  const SideBarX({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;



  @override
  Widget build(BuildContext context) {
    return SidebarX(
      showToggleButton: false,
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        // hoverColor: scaffoldBackgroundColor,
        textStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.black),
        itemTextPadding: const EdgeInsets.only(left: 10),
        itemMargin: const EdgeInsets.symmetric(horizontal: 10),
        selectedItemMargin: const EdgeInsets.symmetric(horizontal: 10),
        selectedItemTextPadding: const EdgeInsets.only(left: 10),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          // border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          // gradient: const LinearGradient(
          //   colors: [accentCanvasColor, canvasColor],
          // ),
          // ignore: prefer_const_literals_to_create_immutables
          boxShadow: [
            BoxShadow(
              color: Colors.white,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.black,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
      ),
      footerDivider: divider,
      headerBuilder: (context, extended) {
        return Container(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "SAMSS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          onTap: () {
            debugPrint('Home');
          },
        ),
        const SidebarXItem(
          icon: Icons.event_available_outlined,
          label: 'Attendance',
        ),
        const SidebarXItem(
          icon: Icons.school_outlined,
          label: 'Classes',
        ),
        const SidebarXItem(
          icon: Icons.manage_accounts_outlined,
          label: 'Accounts',
        ),
        const SidebarXItem(
          icon: Icons.settings_outlined,
          label: 'Configurations',
        ),
      ],
    );
  }
}