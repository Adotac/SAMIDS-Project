import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/admin_controller.dart';

import '../../model/faculty_model.dart';

class FacultyDataSource extends DataTableSource {
  final List<Faculty> _faculties;
  final AdminController adminController;

  FacultyDataSource(this._faculties, this.adminController);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _faculties.length) return const DataRow(cells: []);
    final Faculty faculty = _faculties[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text('${faculty.facultyNo}')),
        DataCell(Text(faculty.lastName)),
        DataCell(Text(faculty.firstName)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _faculties.length;

  @override
  int get selectedRowCount => 0;
}
