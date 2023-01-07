import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';

class AdminAttendance extends StatelessWidget {
  const AdminAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocalAppBar(pageTitle: "Attendance"),
      ],
    );
  }
}
