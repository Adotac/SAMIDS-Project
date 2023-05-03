import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/admin_controller.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';
import 'package:samids_web_app/src/model/student_model.dart';
import 'package:samids_web_app/src/screen/admin/attendance.dart';

import '../model/student_model.dart';

class StudentDataSource extends DataTableSource {
  final List<Student> students;
  final AdminController studentController;

  StudentDataSource(this.students, this.studentController);
  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= students.length) return const DataRow(cells: []);
    final student = students[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(student.studentNo.toString())),
        DataCell(Text(student.rfid.toString())),
        DataCell(Text(student.lastName)),
        DataCell(Text(student.firstName)),
        DataCell(Text(student.course)),
        DataCell(Text(student.year.name.toString())),
      ],
    );
  }

  @override
  int get rowCount => students.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
