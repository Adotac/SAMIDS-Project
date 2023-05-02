// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/constant/constant_values.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:samids_web_app/src/widgets/pagination/subject_data_source.dart';

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

class AdminSubjects extends StatefulWidget {
  static const routeName = '/admin-subjects';
  final AdminController adminController;

  const AdminSubjects({super.key, required this.adminController});

  @override
  State<AdminSubjects> createState() => _AdminSubjectsState();
}

class _AdminSubjectsState extends State<AdminSubjects> {
  final _textEditingController = TextEditingController();

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
      appBarTitle: "Admin Manage Subjects",
      selectedWidgetMarker: 3,
      body: AnimatedBuilder(
          animation: _dataController,
          builder: (context, child) {
            return _webMngUser(context);
          }),
    );
  }

  Widget _webMngUser(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            _buildCard(context, 'Subjects', _searchBarSubject(context),
                _buildSubjectList()),
          ],
        ));
  }

  Expanded _buildCard(BuildContext context, title, searchBar, table) {
    return Expanded(
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
    );
  }

  Widget _buildSubjectList() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Color(0xFFF2F2F2),
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.all(18.0),
        child: _dataTableSubjects(context));
  }

  Widget _dataTableSubjects(BuildContext context) {
    return PaginatedDataTable(
      columns: [
        _dataColumn('Subject No'),
        _dataColumn('Subject Name'),
        _dataColumn('Subject Description', 500.0),
        _dataColumn('Faculty Assigned', 200),
        _dataColumn('Student Count'),
      ],
      showFirstLastButtons: true,
      rowsPerPage: 20,
      onPageChanged: (int value) {
        print('Page changed to $value');
      },
      source: _createStudentDataSource(),
    );
  }

  SubjectDataSource _createStudentDataSource() {
    return SubjectDataSource(
        _dataController.filteredSubjects, _dataController, context);
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
            _dataController.sortSubjects(title);
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

  Widget _searchBarSubject(context) {
    return SizedBox(
        child: TextField(
      onSubmitted: _onSearchSubmittedStudents,
      controller: _textEditingController,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.search_outlined),
        suffixIconColor: Color(0xFFF2F2F2),
        border: InputBorder.none,
        hintText: 'Search Subject',
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
    _dataController.filterSubjects(query);
  }
}
