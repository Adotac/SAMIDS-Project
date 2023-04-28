// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:samids_web_app/src/widgets/pagination/faculty_attendance_data_source.dart';

import '../../controllers/student_controller.dart';
import '../../model/attendance_model.dart';
import '../../model/subjectSchedule_model.dart';
import '../../widgets/card_small.dart';
import '../../widgets/web_view.dart';
import 'package:intl/intl.dart';

class FacultyAttendance extends StatefulWidget {
  static const routeName = '/faculty-attendance';
  final FacultyController dataController;

  const FacultyAttendance({super.key, required this.dataController});

  @override
  State<FacultyAttendance> createState() => _FacultyAttendanceState();
}

class _FacultyAttendanceState extends State<FacultyAttendance> {
  final _textEditingController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayDateFormat = DateFormat('MMMM d, y');
  FacultyController get _dataController => widget.dataController;

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
        if (constraints.maxWidth < 768) {
          return SizedBox();
          // _mobileView(context);
        }
        return _webView(context);
      },
    );
  }

  Widget _webView(BuildContext context) {
    return WebView(
      facultyController: _dataController,
      appBarTitle: "Attendance",
      appBarActionWidget: _searchBar(context),
      selectedWidgetMarker: 1,
      body: AnimatedBuilder(
          animation: _dataController,
          builder: (context, child) {
            return _webAttendanceBody(context);
          }),
    );
  }

  Widget _webAttendanceBody(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.0),
      alignment: Alignment.topLeft,
      child: Card(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.0),
          child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _dataController.dateSelected == null
                            ? _getCurrentYearTerm()
                            : _displayDateFormat
                                .format(_dataController.dateSelected!),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () async {
                          DateTime? selectedDate = await showDatePicker(
                            selectableDayPredicate: (date) =>
                                date.isBefore(DateTime.now()),
                            context: context,
                            initialDate:
                                _dataController.dateSelected ?? DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _dataController.dateSelected = selectedDate;
                              _dataController.getAttendanceAll(
                                _dateFormat
                                    .format(_dataController.dateSelected!),
                              );
                            });
                          } else {
                            _dataController.attendanceReset();
                          }
                        },
                      ),
                      Spacer(),
                      TextButton(
                          onPressed: () async {
                            await _dataController.downloadData(context);
                          },
                          child: Text("Download Table")),
                      TextButton(
                          onPressed: () {
                            _dataController.attendanceReset();
                          },
                          child: Text("Reset"))
                    ],
                  ),
                  _dataTableAttendance(context),
                ],
              )),
        ),
      ),
    );
  }

  String _getCurrentYearTerm() {
    String currentTerm = _dataController.config?.currentTerm ?? '';
    String currentYear = _dataController.config?.currentYear ?? '';

    return '$currentTerm - $currentYear';
  }

  Widget _dataTableAttendance(context) {
    print([
      '_dataController.allAttendanceList',
      _dataController.allAttendanceList.length
    ]);
    return PaginatedDataTable(
      columns: [
        _dataColumn("Student ID"),
        _dataColumn("Name"),
        _dataColumn("Reference ID"),
        _dataColumn("Room"),
        _dataColumn("Subject"),
        _dataColumn("Date"),
        _dataColumn("Day"),
        _dataColumn("Time In"),
        _dataColumn("Time Out"),
        _dataColumn("Remarks"),
      ],
      showFirstLastButtons: true,
      rowsPerPage: 20,
      onPageChanged: (int value) {
        print('Page changed to $value');
      },
      source: _createAttendanceDataSource(),
    );
  }

  AttendanceDataSourceFac _createAttendanceDataSource() {
    return AttendanceDataSourceFac(
      _dataController.filteredAttendanceList,
      _dataController,
      context,
    );
  }

  DataCell dataCell(String data) {
    return DataCell(
      Text(
        data,
      ),
    );
  }

  DataColumn _dataColumn(String title) {
    bool isSortedColumn = _dataController.sortColumn == title;

    return DataColumn(
      label: SizedBox(
        width: 100,
        child: InkWell(
          onTap: () {
            _dataController.sortAttendance(title);
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

  Widget _searchBar(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .30,
      child: TextField(
        autofocus: true,
        onSubmitted: (query) {
          _dataController.filterAttendance(query);
        },
        controller: _textEditingController,
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.search_outlined),
          suffixIconColor: Colors.grey,
          border: InputBorder.none,
          hintText: 'Search',
        ),
      ),
    );
  }
}
