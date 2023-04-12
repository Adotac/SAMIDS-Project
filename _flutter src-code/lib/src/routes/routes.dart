import 'package:flutter/material.dart';

import '../screen/student/attendance.dart';
import '../screen/student/dashboard.dart';

class Routes {
  static Map<String, WidgetBuilder> generateRoutes() {
    return {
      '/dashboard': (context) => StudentDashboard(),
      '/attendance': (context) => StudentAttendance(),
    };
  }
}
