// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/constant/constant_values.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';

import '../../controllers/admin_controller.dart';
import '../../controllers/student_controller.dart';
import '../../model/attendance_model.dart';
import '../../model/student_model.dart';
import '../../model/subjectSchedule_model.dart';
import '../../widgets/pagination/admin_attendance_data_source.dart';
import '../../widgets/card_small.dart';
import '../../widgets/pagination/faculties_data_source.dart';
import '../../widgets/students_data_source.dart';
import '../../widgets/web_view.dart';
import '../page_size_constriant.dart';

class ManageStudent extends StatefulWidget {
  static const routeName = '/admin-manage-student';
  final AdminController adminController;

  const ManageStudent({super.key, required this.adminController});

  @override
  State<ManageStudent> createState() => _ManageStudentState();
}

class _ManageStudentState extends State<ManageStudent> {
  final _textEditingController = TextEditingController();
  final _textEditingControllerFaculty = TextEditingController();

  AdminController get _dataController => widget.adminController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // if (constraints.maxWidth < 768) {
        //   return SizedBox();
        //   // _mobileView(context);
        // }

        if (constraints.maxWidth < 1578 || constraints.maxHeight < 854) {
          return const ScreenSizeWarning();
        }
        return _webView(context);
      },
    );
  }

  Widget _webView(BuildContext context) {
    return WebView(
      appBarTitle: "Manage Student",
      selectedWidgetMarker: 2,
      body: AnimatedBuilder(
          animation: _dataController,
          builder: (context, child) {
            return _webMngUser(context);
          }),
    );
  }

  Widget _webMngUser(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          _buildCard(context, 'Students', _searchBarStudent(context),
              _buildStudentList(), 4),
          _buildCard(context, 'Faculty', _searchBarFaculty(context),
              _buildFacultyList(), 2),
        ],
      ),
    );
  }

  Flexible _buildCard(BuildContext context, title, searchBar, table,
      [int flex = 1]) {
    return Flexible(
      flex: flex,
      child: SingleChildScrollView(
        child: Card(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12.0),
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      decorationThickness: 5.0,
                      fontSize: 24,
                      fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4.0),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.center,
                    child: searchBar),
                table
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Color(0xFFF2F2F2),
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.all(18.0),
        child: _dataTableStudents(context));
  }

  Widget _buildFacultyList() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Color(0xFFF2F2F2),
          width: 2.0,
        ),
      ),
      padding: const EdgeInsets.all(18.0),
      child: _dataTableFaculty(context),
    );
  }

  Widget _dataTableStudents(BuildContext context) {
    return PaginatedDataTable(
      columns: [
        _dataColumn('Student No', 80),
        // _dataColumn('RFID'),
        _dataColumn('Last Name'),
        _dataColumn('First Name'),
        _dataColumn('Course'),
        _dataColumn('Year'),
      ],
      showFirstLastButtons: true,
      rowsPerPage: 20,
      onPageChanged: (int value) {
        print('Page changed to $value');
      },
      source: _createStudentDataSource(),
    );
  }

  StudentDataSource _createStudentDataSource() {
    return StudentDataSource(
      _dataController.filteredStudents,
      _dataController,
    );
  }

  // AttendanceDataSource _createAttendanceDataSource() {
  //   return AttendanceDataSource(
  //     _dataController.allAttendanceList,
  //     _dataController,
  //   );
  // }

  DataColumn _dataColumn(String title, [double width = 100]) {
    bool isSortedColumn = _dataController.sortColumn == title;

    return DataColumn(
      label: SizedBox(
        width: width,
        child: InkWell(
          onTap: () {
            _dataController.sortStudents(title);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (isSortedColumn)
                Icon(
                  _dataController.sortAscending
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
      numeric: false,
    );
  }

  DataColumn _dataColumnFaculty(String title) {
    bool isSortedColumn = _dataController.sortColumnFaculties == title;

    return DataColumn(
      label: SizedBox(
        width: 100,
        child: InkWell(
          onTap: () {
            _dataController.sortFaculties(title);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (isSortedColumn)
                Icon(
                  _dataController.sortAscending
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
      numeric: false,
    );
  }

  Widget _dataTableFaculty(BuildContext context) {
    return Container(
      child: PaginatedDataTable(
        columns: [
          _dataColumnFaculty('Faculty No'),
          _dataColumnFaculty('Last Name'),
          _dataColumnFaculty('First Name'),
        ],
        showFirstLastButtons: true,
        rowsPerPage: 20,
        onPageChanged: (int value) {
          print('Page changed to $value');
        },
        source: _createFacultyDataSource(),
      ),
    );
  }

  FacultyDataSource _createFacultyDataSource() {
    return FacultyDataSource(
        _dataController.filteredFaculties, _dataController, context);
  }

  Widget _searchBarStudent(context) {
    return SizedBox(
        child: TextField(
      onSubmitted: _onSearchSubmittedStudents,
      controller: _textEditingController,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.search_outlined),
        suffixIconColor: Color(0xFFF2F2F2),
        border: InputBorder.none,
        hintText: 'Search Student',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFF2F2F2),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ));
  }

  void _onSearchSubmittedStudents(String query) {
    _dataController.searchStudents(query);
  }

  Widget _searchBarFaculty(context) {
    return SizedBox(
      child: TextField(
        onSubmitted: _onSearchSubmittedFaculties,
        controller: _textEditingControllerFaculty,
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.search_outlined),
          suffixIconColor: Color(0xFFF2F2F2),
          border: InputBorder.none,
          hintText: 'Search Faculty',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFFF2F2F2),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  void _onSearchSubmittedFaculties(String query) {
    _dataController.searchFaculties(query);
  }
}
