// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/student_dashboard.controller.dart';

import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:samids_web_app/src/widgets/mobile_view.dart';

import '../../model/attendance_model.dart';
import '../../widgets/attendance_tile.dart';
import '../../widgets/card_small.dart';
import '../../widgets/side_menu.dart';

class StudentAttendance extends StatefulWidget {
  final StudentDashboardController sdController;

  const StudentAttendance({
    super.key,
    required this.sdController,
  });
  static const routeName = '/student-attendance';

  @override
  State<StudentAttendance> createState() => _StudentAttendanceState();
}

class _StudentAttendanceState extends State<StudentAttendance> {
  final _textEditingController = TextEditingController();
  StudentDashboardController get _sdController => widget.sdController;

  bool isMobile(BoxConstraints constraints) {
    return (constraints.maxWidth <= 450);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 768) {
          return _mobileView(context);
        }
        return _webView(context);
      },
    );
  }

  Widget _webView(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SideMenu(selectedWidgetMarker: 1),
          // Expanded(child: _attendanceBody(context)),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Attendance'),
    );
  }

  // Widget _mobileView(BuildContext context) {
  Widget _mobileView(BuildContext context) {
    return MobileView(
      appBarOnly: true,
      appBarTitle: 'Attendance',
      currentIndex: 1,
      body: _mobileAttendanceBody(context),
    );
  }

  // Widget _mobileAttendanceBody(BuildContext context) {
  //   return Column(
  //     children: [
  //       SizedBox(height: 18),
  //       _searchBar(context),
  //       SizedBox(height: 8),
  //       for (int i = 0; _sdController.allAttendanceList.length > i; i++)
  //         AttendanceTile(
  //           subject: _sdController.allAttendanceList[i].subjectSchedule?.subject
  //                   ?.subjectName ??
  //               'No Subject',
  //           room: _sdController.allAttendanceList[i].subjectSchedule?.room ??
  //               'No Room',
  //           date: _sdController
  //               .formatDate(_getActualTime(_sdController.allAttendanceList[i])),
  //           timeIn: _sdController.allAttendanceList[i].actualTimeIn != null
  //               ? _sdController.formatTime(
  //                   _sdController.allAttendanceList[i].actualTimeIn!)
  //               : 'No Time In',
  //           timeOut: _sdController.allAttendanceList[i].actualTimeOut != null
  //               ? _sdController.formatTime(
  //                   _sdController.allAttendanceList[i].actualTimeOut!)
  //               : 'No Time In',
  //           remarks: _sdController
  //               .getStatusText(_sdController.allAttendanceList[i].remarks.name),
  //         ),
  //     ],
  //   );
  // }

  List<Widget> _mobileAttendanceBody(BuildContext context) {
    return [
      _searchBar(context),
      SizedBox(height: 8),
      Expanded(
        child: ListView.builder(
          itemCount: _sdController.allAttendanceList.length,
          itemBuilder: (BuildContext context, int i) {
            Attendance attendance = _sdController.allAttendanceList[i];
            return AttendanceTile(
              subject: attendance.subjectSchedule?.subject?.subjectName ??
                  'No Subject',
              room: attendance.subjectSchedule?.room ?? 'No Room',
              date: _sdController.formatDate(_getActualTime(attendance)),
              timeIn: attendance.actualTimeIn != null
                  ? _sdController.formatTime(attendance.actualTimeIn!)
                  : 'No Time In',
              timeOut: attendance.actualTimeOut != null
                  ? _sdController.formatTime(attendance.actualTimeOut!)
                  : 'No Time Out',
              remarks: _sdController.getStatusText(attendance.remarks.name),
            );
          },
        ),
      ),
    ];
  }

  DateTime _getActualTime(Attendance attendance) =>
      attendance.actualTimeOut != null
          ? attendance.actualTimeOut!
          : attendance.actualTimeIn != null
              ? attendance.actualTimeIn!
              : DateTime.now();
  // Widget _mobileAttendanceBody(BuildContext context) {
  //   return SingleChildScrollView(
  //     child: ConstrainedBox(
  //       constraints:
  //           BoxConstraints(minHeight: MediaQuery.of(context).size.height),
  //       child: IntrinsicHeight(
  //         child: Column(
  //           children: [
  //             SizedBox(height: 18),
  //             _searchBar(context),
  //             SizedBox(height: 8),
  //             Expanded(
  //               child: ListView.builder(
  //                 itemCount: _sdController.allAttendanceList.length,
  //                 itemBuilder: (BuildContext context, int index) {
  //                   return AttendanceTile(
  //                     subject: '10023 - Programming 1',
  //                     room: 'BCL3',
  //                     date: 'March 05',
  //                     timeIn: '02:12pm',
  //                     timeOut: '03:16pm',
  //                     remarks: 'On-Time',
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _mobileAttendanceBody(BuildContext context) {
  DataRow _sampleDataRow(context) {
    return DataRow(
      // ignore: prefer_const_literals_to_create_immutables
      cells: <DataCell>[
        DataCell(Text('10023 - Programming 1')),
        // DataCell(Text('AD1234KA12')),
        DataCell(Text('BCL3')),
        DataCell(Text('March 05')),
        DataCell(Text('02:12pm')),
        DataCell(Text('03:16pm')),
        DataCell(Text('On-Time')),
      ],
    );
  }

  DataColumn _dataColumn(title) {
    return DataColumn(
      label: Text(
        title,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    ThemeData currentTheme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: currentTheme.dividerColor, width: 1),
      ),
      child: TextField(
        onSubmitted: (_textEditingController) {
          if (kDebugMode) {
            print(_textEditingController.toString());
          }
        },
        controller: _textEditingController,
        decoration: InputDecoration(
          suffixIcon:
              Icon(Icons.search_outlined, color: Theme.of(context).hintColor),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: currentTheme.hintColor),
        ),
      ),
    );
  }
}
