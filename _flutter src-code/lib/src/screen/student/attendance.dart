// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/retry.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';

import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:samids_web_app/src/widgets/mobile_view.dart';

import '../../model/attendance_model.dart';
import 'package:intl/intl.dart';
import '../../widgets/attendance_tile.dart';
import '../../widgets/card_small.dart';
import '../../widgets/pagination/student_attendance_data_source.dart';
import '../../widgets/side_menu.dart';
import '../../widgets/web_view.dart';

class StudentAttendance extends StatefulWidget {
  final StudentController sdController;

  const StudentAttendance({
    Key? key,
    required this.sdController,
  }) : super(key: key);
  static const routeName = '/student-attendance';

  @override
  State<StudentAttendance> createState() => _StudentAttendanceState();
}

class _StudentAttendanceState extends State<StudentAttendance>
    with SingleTickerProviderStateMixin {
  final _textEditingController = TextEditingController();
  StudentController get _sdController => widget.sdController;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayDateFormat = DateFormat('MMMM d, y');
  bool isMobile(BoxConstraints constraints) {
    return (constraints.maxWidth <= 450);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 768) {
          return AnimatedBuilder(
            animation: _sdController,
            builder: (context, child) {
              return _mobileView(context);
            },
          );
        } else {
          return _webView(context);
        }
      },
    );
  }

  Widget _webView(BuildContext context) {
    return WebView(
      studentController: _sdController,
      appBarTitle: "Attendance",
      appBarActionWidget: _searchBar(context),
      selectedWidgetMarker: 1,
      body: AnimatedBuilder(
          animation: _sdController,
          builder: (context, child) {
            return _webAttendanceBody(context);
          }),
    );
  }

  Widget _mobileView(BuildContext context) {
    return MobileView(
      appBarOnly: true,
      appBarTitle: 'Attendance',
      currentIndex: 1,
      body:
          // Text("Attendance")],
          _mobileAttendanceBody(context),
    );
  }

  String getCurrentYearTerm() {
    String currentTerm = _sdController.config?.currentTerm ?? '';
    String currentYear = _sdController.config?.currentYear ?? '';

    return '$currentTerm-$currentYear';
  }

  Widget _webAttendanceBody(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.0),
      child: Card(
          child: Container(
        margin: EdgeInsets.all(10),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _sdController.dateSelected == null
                      ? getCurrentYearTerm()
                      : _displayDateFormat.format(_sdController.dateSelected!),
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
                      initialDate: _sdController.dateSelected ?? DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _sdController.dateSelected = selectedDate;
                        _sdController.getAttendanceAll(
                          _dateFormat.format(_sdController.dateSelected!),
                        );
                      });
                    } else {
                      _sdController.attendanceReset();
                    }
                  },
                ),
                Spacer(),
                TextButton(
                    onPressed: () async {
                      await _sdController.downloadData(context);
                    },
                    child: Text("Download Table")),
                TextButton(
                    onPressed: () {
                      _sdController.attendanceReset();
                    },
                    child: Text("Reset"))
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: _dataTableAttendance(context),
            ),
          ],
        ),
      )),
    );
  }

  Widget _dataTableAttendance(context) {
    return StreamBuilder<Object>(
        stream: null,
        builder: (context, snapshot) {
          return PaginatedDataTable(
              columns: [
                _dataColumn('Reference No'),
                _dataColumn("Subject"),
                _dataColumn("Date"),
                _dataColumn("Day"),
                _dataColumn("Room"),
                _dataColumn("Time in"),
                _dataColumn('Time out'),
                _dataColumn('Remarks'),
                _dataColumn('Action'),
              ],
              showFirstLastButtons: true,
              rowsPerPage: 20,
              onPageChanged: (int value) {
                print('Page changed to $value');
              },
              source: _createAttendanceDataSource());
        });
  }

  AttendanceDataSourceSt _createAttendanceDataSource() {
    return AttendanceDataSourceSt(
        _sdController.filteredAttendanceList, _sdController, context);
  }

  DataColumn _dataColumn(String title) {
    bool isSortedColumn = _sdController.sortColumn == title;

    return DataColumn(
      label: SizedBox(
        width: 100,
        child: InkWell(
          onTap: () {
            _sdController.sortAttendance(title);
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
                  _sdController.sortAscending
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

  List<Widget> _mobileAttendanceBody(BuildContext context) {
    return [
      _searchBarMobile(context),
      SizedBox(height: 8),
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView.builder(
          itemCount: _sdController.filteredAttendanceList.length,
          itemBuilder: (BuildContext context, int i) {
            Attendance attendance = _sdController.filteredAttendanceList[i];
            return AttendanceTile(
              subject: attendance.subjectSchedule?.subject?.subjectName ??
                  'No Subject',
              room: attendance.subjectSchedule?.room ?? 'No Room',
              date: _sdController.formatDate(_getActualTime(attendance)),
              timeIn: attendance.actualTimeIn != null
                  ? _sdController.formatTime(attendance.actualTimeIn!)
                  : 'No Time In',
              timeOut: attendance.actualTimeOut != null
                  ? _sdController.formatTime(attendance.actualTimeOut!)
                  : 'No Time Out',
              remarks: _sdController.getStatusText(attendance.remarks.name),
            );
          },
        ),
      ),
    ];
  }

  DateTime _getActualTime(Attendance attendance) =>
      attendance.actualTimeOut != null
          ? attendance.actualTimeOut!
          : attendance.actualTimeIn != null
              ? attendance.actualTimeIn!
              : DateTime.now();

  Widget _searchBar(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .30,
      child: TextField(
        autofocus: true,
        onSubmitted: (query) {
          _sdController.filterAttendance(query);
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

  Widget _searchBarMobile(context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      width: double.infinity,
      child: TextField(
        autofocus: true,
        onSubmitted: (query) {
          print(query);
          _sdController.filterAttendance(query);
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
