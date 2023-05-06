import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:samids_web_app/src/controllers/admin_controller.dart';

import '../../model/faculty_model.dart';

class FacultyDataSource extends DataTableSource {
  final List<Faculty> _faculties;
  final AdminController adminController;
  final context;
  int _selectedRowIndex = -1;

  FacultyDataSource(this._faculties, this.adminController, this.context);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _faculties.length) return const DataRow(cells: []);
    final Faculty faculty = _faculties[index];
    final isSelected = _selectedRowIndex == index;
    final backgroundColor = isSelected
        ? Colors.grey.withOpacity(0.3)
        : (index % 2 == 0 ? Colors.white : Colors.grey.withOpacity(0.1));
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
      // onSelectChanged: (bool? value) {
      //   // notifyListeners();

      // },
      cells: [
        DataCell(
          mouseRegion(faculty, faculty.facultyNo.toString()),
        ),
        DataCell(
          mouseRegion(faculty, faculty.lastName),
        ),
        DataCell(
          mouseRegion(faculty, faculty.firstName),
        ),
      ],
    );
  }

  MouseRegion mouseRegion(Faculty faculty, String title) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          adminController.selectedFaculty = faculty;
          adminController.getFacultyClassesTemp(faculty.facultyNo);
        },
        child: Text(title),
      ),
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
