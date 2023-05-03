import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:samids_web_app/src/controllers/admin_controller.dart';

import '../../model/faculty_model.dart';

class FacultyDataSource extends DataTableSource {
  final List<Faculty> _faculties;
  final AdminController adminController;
  final context;
  FacultyDataSource(this._faculties, this.adminController, this.context);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _faculties.length) return const DataRow(cells: []);
    final Faculty faculty = _faculties[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text('${faculty.facultyNo}'),
        ),
        DataCell(
          GestureDetector(
            child: Text(faculty.lastName),
            onTap: () {
              // Handle cell tap here
              adminController.selectedFaculty = faculty;
              adminController.getFacultyClassesTemp(faculty.facultyNo);

              // _showEditDialog(context, faculty.lastName, faculty, 'Last Name');
            },
          ),
        ),
        DataCell(
          GestureDetector(
            child: Text(faculty.firstName),
            onTap: () {
              adminController.selectedFaculty = faculty;
              adminController.getFacultyClassesTemp(faculty.facultyNo);
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _faculties.length;

  @override
  int get selectedRowCount => 0;

  void _showEditDialog(BuildContext context, String initialValue,
      Faculty faculty, String field) async {
    TextEditingController controller =
        TextEditingController(text: initialValue);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update the faculty details
              if (field == 'Last Name') {
                await adminController.onUpdateFaculty(
                  faculty.facultyNo,
                  faculty.firstName,
                  controller.text,
                );
              } else if (field == 'First Name') {
                await adminController.onUpdateFaculty(
                  faculty.facultyNo,
                  controller.text,
                  faculty.lastName,
                );
              }
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
