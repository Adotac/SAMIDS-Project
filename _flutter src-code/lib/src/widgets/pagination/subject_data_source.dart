import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samids_web_app/src/controllers/admin_controller.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';
import 'package:samids_web_app/src/model/subjectSchedule_model.dart';

import '../../model/subject_model.dart';

class SubjectDataSource extends DataTableSource {
  final List<SubjectSchedule> subjectSchedule;
  final AdminController _dataController;
  final BuildContext context;

  SubjectDataSource(this.subjectSchedule, this._dataController, this.context);
  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => subjectSchedule.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= subjectSchedule.length) return const DataRow(cells: []);
    final SubjectSchedule schedule = subjectSchedule[index];
    return _buildSubjectRow(context, schedule);
  }

  DataRow _buildSubjectRow(BuildContext context, SubjectSchedule schedule) {
    return DataRow(
      cells: [
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                schedule.schedId.toString(),
              ),
            ),
          ),
        ),
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                schedule.subject?.subjectName ?? 'No subject name',
              ),
            ),
          ),
        ),
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              schedule.subject?.subjectDescription ?? 'No subject description',
            ),
          ),
        ),
        DataCell(
          SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: Text(schedule.room)),
        ),
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(formatTime(schedule.timeStart)),
          ),
        ),
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(formatTime(schedule.timeEnd)),
          ),
        ),
        DataCell(
          SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: Text(schedule.day)),
        ),
        // DataCell(
        //   SingleChildScrollView(
        //       scrollDirection: Axis.horizontal,
        //       child: Text('${schedule.subject?.students?.length  ?? '0'}')),
        // ),
      ],
    );
  }

  String formatTime(DateTime dateTime) {
    final formattedTime = DateFormat('hh:mm a').format(dateTime);
    return formattedTime;
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
}
