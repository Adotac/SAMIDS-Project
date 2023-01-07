// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/screen/admin/screen_navigator.dart';
import 'package:samids_web_app/src/screen/sidebar_navigator.dart';
import 'package:sidebarx/sidebarx.dart';

class AdminView extends StatelessWidget {
  AdminView({Key? key}) : super(key: key);

  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final isSmallScreen = MediaQuery.of(context).size.width < 600;
        return Scaffold(
          
          key: _key,
          // drawer: ExampleSidebarX(controller: _controller),
          body: Row(
            children: [
              if (!isSmallScreen) SideBarX(controller: _controller),
              Expanded(
                child: Center(
                  child: ScreenNavigator(
                    controller: _controller,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

