import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/admin_controller.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';
import 'package:samids_web_app/src/model/student_model.dart';
import 'package:samids_web_app/src/screen/admin/attendance.dart';

import '../model/student_model.dart';

class StudentDataSource extends DataTableSource {
  final List<Student> students;
  final AdminController adminController;
  final BuildContext context;

  int _selectedRowIndex = -1;
  StudentDataSource(this.students, this.adminController, this.context);
  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= students.length) return const DataRow(cells: []);
    final student = students[index];
    final isSelected = _selectedRowIndex == index;
    final backgroundColor = isSelected
        ? Colors.grey.withOpacity(0.3)
        : (index % 2 == 0
            ? Colors.white
            : Theme.of(context).primaryColor.withOpacity(0.05));
    return DataRow.byIndex(
      index: index,
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected))
          return Theme.of(context).colorScheme.primary.withOpacity(0.1);
        if (states.contains(MaterialState.hovered))
          return Theme.of(context).colorScheme.primary.withOpacity(0.05);
        return backgroundColor;
      }),
      cells: [
        DataCell(mouseRegion(student, student.studentNo.toString())),
        // DataCell(Text(student.rfid.toString())),
        DataCell(mouseRegion(student, student.lastName)),
        DataCell(mouseRegion(student, student.firstName)),
        DataCell(mouseRegion(student, student.course)),
        DataCell(mouseRegion(student, '${student.year.index}')),
      ],
    );
  }

  MouseRegion mouseRegion(Student student, String title) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          adminController.selectedStudent = student;
          adminController.getStudentClassesTemp();
        },
        child: Text(title),
      ),
    );
  }

  @override
  int get rowCount => students.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
