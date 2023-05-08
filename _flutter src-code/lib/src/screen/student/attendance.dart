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
import '../page_size_constriant.dart';

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
  StudentController get _dataController => widget.sdController;
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
        if (constraints.maxWidth < 360 || constraints.maxHeight < 650) {
          return const ScreenSizeWarning();
        }
        if (constraints.maxWidth < 450) {
          return AnimatedBuilder(
            animation: _dataController,
            builder: (context, child) {
              return _mobileView(context);
            },
          );
        }

        if (constraints.maxWidth < 1578 || constraints.maxHeight < 854) {
          return const ScreenSizeWarning();
        }
        return _webView(context);
      },
    );
  }

  Widget _webView(BuildContext context) {
    return WebView(
      studentController: _dataController,
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

  Widget _mobileView(BuildContext context) {
    return MobileView(
      routeName: StudentAttendance.routeName,
      appBarOnly: true,
      appBarTitle: 'Attendance',
      currentIndex: 1,
      body:
          // Text("Attendance")],
          _mobileAttendanceBody(context),
    );
  }

  String _getCurrentYearTerm() {
    String currentTerm = _dataController.config?.currentTerm ?? '';
    String currentYear = _dataController.config?.currentYear ?? '';

    return '$currentTerm - $currentYear';
  }

  String _getCurrentYearTermMobile() {
    return _dataController.config?.currentTerm ?? '';
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
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _dataController.dateSelected = selectedDate;
                        // _dataController.getAttendanceAll(
                        //   _dateFormat.format(_dataController.dateSelected!),
                        // );
                      });
                    } else {
                      // _dataController.attendanceReset();
                    }
                  },
                ),
                Spacer(),
                TextButton(
                    onPressed: () async {
                      await _dataController.downloadData(context);
                    },
                    child: Text("Download Table")),
                const SizedBox(width: 4.0),
                const SizedBox(width: 4.0),
                TextButton(
                    onPressed: () {
                      // _dataController.attendanceReset();
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
                _dataColumn("Subject"),
                _dataColumn("Date"),
                _dataColumn("Room"),
                _dataColumn("Time in"),
                _dataColumn('Time out'),
                _dataColumn('Remarks'),
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
        _dataController.filteredAttendanceList, _dataController, context);
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

  List<Widget> _mobileAttendanceBody(BuildContext context) {
    return [
      _searchBarMobile(context),
      SizedBox(height: 8),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 6.0),
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 8.0,
              ),
              Text(
                _dataController.dateSelected == null
                    ? _getCurrentYearTermMobile()
                    : _displayDateFormat.format(_dataController.dateSelected!),
                style: TextStyle(
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
                    initialDate: _dataController.dateSelected ?? DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _dataController.dateSelected = selectedDate;
                      // _dataController.getAttendanceAll(
                      //   _dateFormat.format(_dataController.dateSelected!),
                      // );
                    });
                  } else {
                    // _dataController.attendanceReset();
                  }
                },
              ),
              Spacer(),
              TextButton(
                  onPressed: () async {
                    await _dataController.downloadData(context);
                  },
                  child: Text("Download")),
              const SizedBox(width: 4.0),
              TextButton(
                  onPressed: () {
                    // _dataController.attendanceReset();
                  },
                  child: Text("Reset"))
            ],
          ),
        ),
      ),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView.builder(
          itemCount: _dataController.filteredAttendanceList.length,
          itemBuilder: (BuildContext context, int i) {
            Attendance attendance = _dataController.filteredAttendanceList[i];
            return AttendanceTile(
              subject: attendance.subjectSchedule?.subject?.subjectName ??
                  'No Subject',
              room: attendance.subjectSchedule?.room ?? 'No Room',
              date: _dataController.formatDate(_getActualTime(attendance)),
              timeIn: attendance.actualTimeIn != null
                  ? _dataController.formatTime(attendance.actualTimeIn!)
                  : 'No Time In',
              timeOut: attendance.actualTimeOut != null
                  ? _dataController.formatTime(attendance.actualTimeOut!)
                  : 'No Time Out',
              remarks: _dataController
                  .getStatusText(attendance.remarks?.name ?? 'Pending'),
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

  Widget _searchBarMobile(context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      width: double.infinity,
      child: TextField(
        autofocus: true,
        onSubmitted: (query) {
          print(query);
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
