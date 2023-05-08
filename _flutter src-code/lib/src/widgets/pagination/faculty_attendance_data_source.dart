import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';

import '../../model/attendance_model.dart';

class AttendanceDataSourceFac extends DataTableSource {
  final List<Attendance> attendanceList;
  final FacultyController _dataController;
  final BuildContext context;

  AttendanceDataSourceFac(
      this.attendanceList, this._dataController, this.context);
  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => attendanceList.length;
  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= attendanceList.length) return const DataRow(cells: []);
    final Attendance attendance = attendanceList[index];
    return _buildAttendanceRow(context, attendance);
  }

  DataRow _buildAttendanceRow(BuildContext context, Attendance attendance) {
    return DataRow(
      cells: [
        dataCell(attendance.student?.studentNo.toString() ?? 'No student ID'),
        dataCell(
            '${attendance.student?.firstName} ${attendance.student?.lastName}'),
        // dataCell(attendance.attendanceId.toString()),
        dataCell(attendance.subjectSchedule?.room ?? 'No Room'),
        dataCell(attendance.subjectSchedule?.subject?.subjectName ??
            'No subject name'),
        dataCell(_dataController.formatDate(attendance.actualTimeIn!)),
        // dataCell(attendance.subjectSchedule?.day ?? 'No Date'),

        dataCell(attendance.actualTimeIn != null
            ? _dataController.formatTime(attendance.actualTimeIn!)
            : 'No Time In'),
        dataCell(attendance.actualTimeOut != null
            ? _dataController.formatTime(attendance.actualTimeOut!)
            : 'No Time Out'),
        DataCell(
          _dataController.getStatusText(attendance.remarks?.name ?? 'Pending'),
        ),
      ],
    );
  }

  String _getDayOfWeek(DateTime dateTime) {
    switch (dateTime.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thurs';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
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

  DataCell dataCell(String data) {
    return DataCell(
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            data,
          ),
        ),
      ),
    );
  }
}
