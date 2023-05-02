import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/admin_controller.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';

import '../../model/subject_model.dart';

class SubjectDataSource extends DataTableSource {
  final List<Subject> subjectList;
  final AdminController _dataController;
  final BuildContext context;

  SubjectDataSource(this.subjectList, this._dataController, this.context);
  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => subjectList.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= subjectList.length) return const DataRow(cells: []);
    final Subject subject = subjectList[index];
    return _buildSubjectRow(context, subject);
  }

  DataRow _buildSubjectRow(BuildContext context, Subject subject) {
    return DataRow(
      cells: [
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                subject.subjectID.toString(),
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
                subject.subjectName,
              ),
            ),
          ),
        ),
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              subject.subjectDescription,
            ),
          ),
        ),
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                subject.students?.length.toString() ?? '0',
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
                subject.faculties?.length.toString() ?? '0',
              ),
            ),
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
}
