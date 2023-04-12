import 'package:flutter/material.dart';

class MobileView extends StatelessWidget {
  final Widget body;
  final String appBarTitle;

  const MobileView({
    Key? key,
    required this.body,
    required this.appBarTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            label: 'Dashboard ',
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.event_available_outlined,
              ),
              label: 'Attendance'),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.school_outlined,
            ),
            label: 'Classes',
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
