import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';

import '../../model/attendance_model.dart';

class AttendanceDataSourceSt extends DataTableSource {
  final List<Attendance> attendanceList;
  final StudentController sdController;
  final BuildContext context;

  AttendanceDataSourceSt(this.attendanceList, this.sdController, this.context);
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
        dataCell(attendance.subjectSchedule?.subject?.subjectName ??
            'No subject name'),
        dataCell(
          '${attendance.subjectSchedule?.faculty?.firstName ?? 'No Faculty'} ${attendance.subjectSchedule?.faculty?.lastName ?? ''} ',
        ),
        dataCell(sdController.formatDate(attendance.actualTimeIn!)),
        dataCell(
          attendance.subjectSchedule?.room.toString() ?? 'No room code',
        ),
        dataCell(attendance.actualTimeIn != null
            ? sdController.formatTime(attendance.actualTimeIn!)
            : 'Pending'),
        dataCell(attendance.actualTimeOut != null
            ? sdController.formatTime(attendance.actualTimeOut!)
            : 'Pending'),
        DataCell(
            sdController.getStatusText(attendance.remarks?.name ?? 'Pending')),
        // DataCell(
        //   Row(
        //     children: [
        //       IconButton(
        //           onPressed: () => _showReportAttendanceDialog(context),
        //           icon: Icon(
        //             Icons.report_gmailerrorred_outlined,
        //             color: Theme.of(context).primaryColor,
        //           )),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Future<void> _showReportAttendanceDialog(BuildContext context) async {
    TextEditingController _textFieldController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Attendance Issue'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  'Please provide a brief description of the issue:',
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _textFieldController,
                  decoration: const InputDecoration(
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
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                // Process the submitted issue
                Navigator.of(context).pop();
                await _showLoadingDialog(context);
                await Future.delayed(Duration(seconds: 2));
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
