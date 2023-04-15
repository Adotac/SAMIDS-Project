// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/student_dashboard.controller.dart';

import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:samids_web_app/src/widgets/mobile_view.dart';

import '../../model/attendance_model.dart';
import '../../widgets/attendance_dialog_report.dart';
import '../../widgets/attendance_tile.dart';
import '../../widgets/card_small.dart';
import '../../widgets/side_menu.dart';
import '../../widgets/web_view.dart';

class StudentAttendance extends StatefulWidget {
  final StudentDashboardController sdController;

  const StudentAttendance({
    Key? key,
    required this.sdController,
  }) : super(key: key);
  static const routeName = '/student-attendance';

  @override
  State<StudentAttendance> createState() => _StudentAttendanceState();
}

class _StudentAttendanceState extends State<StudentAttendance>
    with SingleTickerProviderStateMixin {
  final _textEditingController = TextEditingController();
  late AnimationController _animationController;
  StudentDashboardController get _sdController => widget.sdController;

  bool isMobile(BoxConstraints constraints) {
    return (constraints.maxWidth <= 450);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    return WebView(
      appBarTitle: "Attendance",
      appBarActionWidget: _searchBar(context),
      selectedWidgetMarker: 1,
      body: AnimatedBuilder(
          animation: _sdController,
          builder: (context, child) {
            return _webAttendanceBody(context);
          }),
    );
  }

  Widget _mobileView(BuildContext context) {
    return MobileView(
      appBarOnly: true,
      appBarTitle: 'Attendance',
      currentIndex: 1,
      body: _mobileAttendanceBody(context),
    );
  }

  Widget _webAttendanceBody(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Expanded(child: Card(child: _dataTableRecentLogs(context))),
      ),
    );
  }

  Widget _dataTableRecentLogs(context) {
    return SizedBox(
      // width: MediaQuery.of(context).size.width * .8,
      child: DataTable(
        columns: const [
          DataColumn(
            numeric: true,
            label: Text('Reference No.'),
          ),
          DataColumn(
            label: Text('Subject'),
          ),
          DataColumn(
            label: Text('Room'),
          ),
          DataColumn(
            label: Text('Time in'),
          ),
          DataColumn(
            label: Text('Time out'),
          ),
          DataColumn(
            label: Text('Remarks'),
          ),
          DataColumn(
            label: Text('Actions'),
          ),
        ],
        rows: _sdController.allAttendanceList
            .map((attendance) => _buildDataRowRecentLogs(context, attendance))
            .toList(),
      ),
    );
  }

  DataRow _buildDataRowRecentLogs(BuildContext context, Attendance attendance) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            attendance.attendanceId.toString(),
          ),
        ),
        DataCell(
          Text(
            attendance.subjectSchedule?.subject?.subjectName ??
                'No subject name',
          ),
        ),
        DataCell(
          Text(
            attendance.subjectSchedule?.room.toString() ?? 'No room code',
          ),
        ),
        DataCell(
          Text(
            attendance.actualTimeIn != null
                ? _sdController.formatTime(attendance.actualTimeIn!)
                : 'No Time In',
          ),
        ),
        DataCell(
          Text(
            attendance.actualTimeOut != null
                ? _sdController.formatTime(attendance.actualTimeOut!)
                : 'No Time Out',
          ),
        ),
        DataCell(
          _sdController.getStatusText(attendance.remarks.name),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                  onPressed: () => _showReportAttendanceDialog(context),
                  icon: Icon(
                    Icons.report_gmailerrorred_outlined,
                    color: Theme.of(context).primaryColor,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => true,
          child: AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Sending...'),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showReportAttendanceDialog(BuildContext context) async {
    TextEditingController _textFieldController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report Attendance Issue'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please provide a brief description of the issue:',
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _textFieldController,
                  decoration: InputDecoration(
                    hintText: 'Enter issue description',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                // Process the submitted issue
                Navigator.of(context).pop();
                await _showLoadingDialog(context);
                await Future.delayed(Duration(seconds: 2));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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

  Widget _searchBar(BuildContext context) {
    ThemeData currentTheme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.rectangle,
        border: Border.all(color: currentTheme.dividerColor, width: 1),
      ),
      child: TextField(
        onSubmitted: (textEditingController) {
          if (kDebugMode) {
            print(textEditingController.toString());
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
