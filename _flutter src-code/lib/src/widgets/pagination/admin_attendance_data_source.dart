import 'package:flutter/material.dart';

import '../../model/attendance_model.dart';

class AttendanceDataSourceAd extends DataTableSource {
  final List<Attendance> _attendanceList;
  final _dataController;

  AttendanceDataSourceAd(this._attendanceList, this._dataController);
  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _attendanceList.length;
  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _attendanceList.length) return const DataRow(cells: []);
    final Attendance attendance = _attendanceList[index];
    return _buildAttendanceRow(attendance);
  }

  DataRow _buildAttendanceRow(Attendance attendance) {
    return DataRow(
      cells: [
        dataCell(attendance.student?.studentNo.toString() ?? 'No student ID'),
        dataCell(
            '${attendance.student?.firstName} ${attendance.student?.lastName}'),
        dataCell(attendance.attendanceId.toString()),
        dataCell(attendance.subjectSchedule?.room ?? 'No Room'),
        dataCell(attendance.subjectSchedule?.subject?.subjectName ??
            'No subject name'),
        dataCell(_dataController.formatDate(attendance.actualTimeIn!)),
        dataCell(attendance.subjectSchedule?.day ?? 'No Date'),
        dataCell(attendance.actualTimeIn != null
            ? _dataController.formatTime(attendance.actualTimeIn!)
            : 'No Time In'),
        dataCell(attendance.actualTimeOut != null
            ? _dataController.formatTime(attendance.actualTimeOut!)
            : 'No Time Out'),
        DataCell(
          _dataController.getStatusText(attendance.remarks.name),
        ),
      ],
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
