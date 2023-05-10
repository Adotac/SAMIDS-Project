// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/services/attendance.services.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:samids_web_app/src/widgets/pagination/faculty_attendance_data_source.dart';

import '../../controllers/student_controller.dart';
import '../../model/attendance_model.dart';
import '../../model/subjectSchedule_model.dart';
import '../../widgets/attendance_tile.dart';
import '../../widgets/attendance_tile_faculty.dart';
import '../../widgets/card_small.dart';
import '../../widgets/mobile_view.dart';
import '../../widgets/web_view.dart';
import 'package:intl/intl.dart';

import '../page_size_constriant.dart';

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

  Widget _mobileView(BuildContext context) {
    return MobileView(
      routeName: FacultyAttendance.routeName,
      appBarOnly: true,
      appBarTitle: 'Attendance',
      currentIndex: 1,
      body: [
        SingleChildScrollView(
          child: Column(
            children: [..._mobileAttendanceBody(context)],
          ),
        )
      ],
    );
  }

  String _getCurrentYearTermMobile() {
    return _dataController.config?.currentTerm ?? '';
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
                      _dataController.setParams(
                          date: _dataController.dateSelected);
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
              // TextButton(
              //     onPressed: () {
              //       // _dataController.attendanceReset();
              //     },
              //     child: Text("Reset"))
            ],
          ),
        ),
      ),
      ...List<Widget>.generate(_dataController.allAttendanceList.length,
          (int index) {
        Attendance attendance = _dataController.allAttendanceList[index];
        return AttendanceTileFac(
          studentNo:
              attendance.student?.studentNo.toString() ?? 'No student ID',
          name:
              '${attendance.student?.firstName} ${attendance.student?.lastName}',
          day: attendance.subjectSchedule?.day ?? 'No Day',
          // referenceNo: attendance.attendanceId.toString(),
          subject:
              attendance.subjectSchedule?.subject?.subjectName ?? 'No Subject',
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
      }),
    ];
  }

  DateTime _getActualTime(Attendance attendance) =>
      attendance.actualTimeOut != null
          ? attendance.actualTimeOut!
          : attendance.actualTimeIn != null
              ? attendance.actualTimeIn!
              : DateTime.now();

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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      scrollDirection: Axis.vertical,
      child: AnimatedBuilder(
          animation: _dataController,
          builder: (context, child) {
            return _dataTableAttendance(context);
          }),
    );
  }

  Widget _dataTableAttendance(context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () async {
                      await _dataController.downloadData(context);
                    },
                    child: Text("Download Table")),
              ],
            ),
            PaginatedDataTable(
              columns: [
                _dataColumn("Student ID"),
                _dataColumn("Name"),
                // _dataColumn("Reference ID"),
                _dataColumn("Room"),
                _dataColumn("Subject"),
                _dataColumn("Date"),
                // _dataColumn("Day"),
                _dataColumn("Time In"),
                _dataColumn("Time Out"),
                _dataColumn("Remarks"),
                _dataColumn("Action"),
              ],
              showFirstLastButtons: true,
              rowsPerPage: _dataController.pageSize,
              onPageChanged: (int value) {
                print('Page changed to $value');
                _dataController.setParams(page: value);
              },
              source: _createAttendanceDataSource(),
            ),
          ],
        ),
      ),
    );
  }

  // AttendanceDataSource _createAttendanceDataSource() {
  //   return AttendanceDataSource(
  //     _dataController.allAttendanceList,
  //     _dataController,p
  //   );
  // }

  AttendanceDataSourceFac _createAttendanceDataSource() {
    return AttendanceDataSourceFac(
        _dataController.allAttendanceList, _dataController, context);
  }

  DataColumn _dataColumn(String title) {
    bool isSortedColumn = _dataController.sortColumn == title;

    return DataColumn(
      label: SizedBox(
        width: 150,
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
      // padding: const EdgeInsets.symmetric(horizontal: 12),
      // height: 42,
      width: MediaQuery.of(context).size.width * .30,
      // decoration: BoxDecoration(
      //     color: Colors.white,
      //     shape: BoxShape.rectangle,
      //     borderRadius: BorderRadius.circular(5),
      //     border: Border.all(color: Colors.grey, width: 1)),
      child: TextField(
        autofocus: true,
        onChanged: (value) {
          _dataController.setParams(search: value);
          //_dataController.getAttendanceAll();
        },
        onSubmitted: (value) {
          // Call filterAttendance with the search query entered by the user
          _dataController.setParams(search: value);
          //_dataController.getAttendanceAll();
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
    return SizedBox(
      width: MediaQuery.of(context).size.width * .90,
      child: TextField(
        autofocus: true,
        onSubmitted: (query) {
          // Call filterAttendance with the search query entered by the user
          _dataController.setParams(search: query);
          _dataController.getAttendanceAll();
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
    //  _dataColumn("Subject"),
    //             _dataColumn("Subject"),
    //             _dataColumn("Date"),
    //             _dataColumn("Room"),
    //             _dataColumn("Time in"),
    //             _dataColumn('Time out'),
    //             _dataColumn('Remarks'),