// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/model/subjectSchedule_model.dart';

import 'package:samids_web_app/src/screen/student/attendance.dart';
import 'package:samids_web_app/src/screen/student/classes.dart';
import 'package:samids_web_app/src/widgets/circular_viewer.dart';
import 'package:samids_web_app/src/widgets/custom_list_tile.dart';
import 'package:samids_web_app/src/widgets/side_menu.dart';
import 'package:samids_web_app/src/widgets/student_info_card.dart';

import '../../controllers/student_controller.dart';

import '../../model/attendance_model.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/card_small.dart';
import '../../widgets/card_small_mobile.dart';
import '../../widgets/data_number.dart';
import '../../widgets/mobile_view.dart';
import '../../widgets/recent_logs_table.dart';
import '../../widgets/title_medium_text.dart';
import 'package:intl/intl.dart';

import '../../widgets/web_view.dart';
import '../page_size_constriant.dart';

// ignore: must_be_immutable
class StudentDashboard extends StatefulWidget {
  static const routeName = '/student-dashboard';
  final StudentController sdController;
  const StudentDashboard({super.key, required this.sdController});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  StudentController get _sdController => widget.sdController;
  // add on init
  @override
  void initState() {
    _sdController.getConfig();
    _sdController.getAttendanceToday();
    //_sdController.getAttendanceAll(null);
    _sdController.getStudentClasses();
    _sdController.startStream(context);
    super.initState();
  }

  bool isMobile(BoxConstraints constraints) {
    return (constraints.maxWidth <= 450);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
      if (constraints.maxWidth < 360 || constraints.maxHeight < 650) {
        return const ScreenSizeWarning();
      }
      if (isMobile(constraints)) {
        return _mobileView();
      }
      if (constraints.maxWidth < 1578 || constraints.maxHeight < 854) {
        return const ScreenSizeWarning();
      }

      return _webView();
    });
  }

  Widget _webView() {
    return AnimatedBuilder(
      animation: _sdController,
      builder: (context, child) {
        return !_sdController.isAllAttendanceCollected
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor, // Customize the color
                  ),
                ),
              )
            : WebView(
                studentController: _sdController,
                appBarTitle: "Dashboard",
                selectedWidgetMarker: 0,
                body: Container(
                  alignment: Alignment.topCenter,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // StudentInfoCard(student: _sdController.student),
                                Row(
                                  children: [
                                    Flexible(
                                        flex: 1,
                                        child: Card(
                                          child: StudentInfoCard(
                                            id: _sdController.student.studentNo,
                                            year: _sdController
                                                .student.year.index
                                                .toString(),
                                            course:
                                                _sdController.student.course,
                                            firstName:
                                                _sdController.student.firstName,
                                            lastName:
                                                _sdController.student.lastName,
                                          ),
                                        )),
                                    Flexible(
                                      flex: 1,
                                      child: _overviewCard(5),
                                    ),
                                  ],
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: _webRecentLogsCard(
                                        context,
                                      ),
                                    ),
                                    Expanded(
                                      child: _myClassesCard(
                                        context,
                                      ),
                                    ),
                                    // _myClassesCard(context)
                                  ],
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }

  Widget _mobileView() {
    return AnimatedBuilder(
      animation: _sdController,
      builder: (context, child) {
        return MobileView(
            routeName: StudentDashboard.routeName,
            currentIndex: 0,
            appBarTitle: 'Dashboard',
            userName:
                '${_sdController.student.firstName} ${_sdController.student.lastName}',
            body: _sdController.isCountCalculated
                ? [_mobileOverviewCard(2, 0), _mobileRecentLogsCard(0)]
                : [
                    Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor, // Customize the color
                        ),
                      ),
                    ),
                  ]);
      },
    );
  }

  Widget _myClassesCard(context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleMediumText(title: "My Classes"),
                Text(
                  _getCurrentYearTerm(),
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            _dataTableClasses(context),
          ],
        ),
      ),
    );
  }

  Widget _dataTableClasses(context) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('Subject'),
          ),
          DataColumn(
            label: Text('Room'),
          ),
          DataColumn(
            label: Text('Time'),
          ),
          DataColumn(
            label: Text('Day'),
          ),
        ],
        rows: _sdController.studentClasses
            .map((attendance) => _buildDataRowClasses(context, attendance))
            .toList(),
      ),
    );
  }

  DataRow _buildDataRowClasses(BuildContext context, SubjectSchedule schedule) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            "${schedule.schedId} - ${schedule.subject?.subjectName ?? 'No subject name'}",
            style: TextStyle(fontSize: 14),
          ),
        ),
        DataCell(
          Text(
            schedule.room.toString(),
            style: TextStyle(fontSize: 14),
          ),
        ),
        DataCell(
          Text(
            getTimeStartEnd(schedule),
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            schedule.day,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String getTimeStartEnd(SubjectSchedule subjectSchedule) {
    final timeStart = _sdController.formatTime(subjectSchedule.timeStart);
    final timeEnd = _sdController.formatTime(subjectSchedule.timeEnd);
    return '$timeStart - $timeEnd';
  }

  DataRow _buildDataRowRecentLogs(BuildContext context, Attendance attendance) {
    return DataRow(
      cells: [
        DataCell(
          Expanded(
            child: Text(
              attendance.subjectSchedule?.subject?.subjectName ??
                  'No subject name',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Expanded(
            child: Text(
              attendance.subjectSchedule?.room.toString() ?? 'No subject id',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Expanded(
            child: Text(
              attendance.actualTimeIn != null
                  ? _sdController.formatTime(attendance.actualTimeIn!)
                  : 'No Time In',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DataCell(
          Expanded(
            child: Text(
              attendance.actualTimeOut != null
                  ? _sdController.formatTime(attendance.actualTimeOut!)
                  : 'No Time out',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DataCell(
          Expanded(
              child: _sdController
                  .getStatusText(attendance.remarks?.name ?? "Pending")),
        ),
      ],
    );
  }

  // Widget _webRecentLogsCard(context) {
  //   return Card(
  //     child: CardSmall(
  //       title: "Recent Activity",
  //       isShadow: false,
  //       child:
  //           // SizedBox(width: 800, child: Text('No recent activity')),
  //           _dataTableRecentLogs(context),
  //     ),
  //   );
  // }
  String _getCurrentYearTerm() {
    String currentTerm = _sdController.config?.currentTerm ?? '';
    String currentYear = _sdController.config?.currentYear ?? '';

    return '$currentTerm-$currentYear';
  }

  Widget _webRecentLogsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleMediumText(title: "Recent Activity"),
                Text(
                  _formatCurrentDate(),
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text('Subject'),
                  ),
                  DataColumn(
                    label: Text('Room'),
                  ),
                  DataColumn(
                    label: Text('Time In'),
                  ),
                  DataColumn(
                    label: Text('Time Out'),
                  ),
                  DataColumn(
                    label: Text('Remarks'),
                  ),
                ],
                rows: _sdController.attendance
                    .map((attendance) =>
                        _buildDataRowRecentLogs(context, attendance))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrentDate() {
    return DateFormat('MMMM d, y').format(DateTime.now());
  }

  Widget _mobileRecentLogsCard([flexValue = 1]) {
    return MobileSmallCard(
      isShadow: false,
      sideTitle: _formatCurrentDate(),
      title: "Recent Activity",
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _sdController.attendance.length,
        itemBuilder: (BuildContext context, int index) {
          Attendance attendance = _sdController.attendance[index];
          return CustomListTile(
            title: attendance.subjectSchedule?.subject?.subjectName ??
                'No subject name',
            subtitle: _sdController
                .getStatusText(attendance.remarks?.name ?? 'Pending'),
            leadingIcon: Icon(getStatusIcon(attendance?.remarks),
                color: Theme.of(context).scaffoldBackgroundColor),
            leadingColors:
                _sdController.getStatusColor(attendance.remarks, context),
            trailingText: _sdController.formatTime(_getActualTime(attendance)),
            subTrailingText:
                attendance.subjectSchedule?.room.toString() ?? 'No subject id',
          );
        },
      ),
    );
  }

  DateTime _getActualTime(Attendance attendance) =>
      attendance.actualTimeOut != null
          ? attendance.actualTimeOut!
          : attendance.actualTimeIn != null
              ? attendance.actualTimeIn!
              : DateTime.now();

  IconData getStatusIcon(Remarks? remarks) {
    return Icons.timer_outlined;
  }

  Widget _overviewCard(leadingFlex, [flexValue = 1]) {
    double totalLogs = _sdController.allAttendanceList.length.toDouble();
    return SizedBox(
      height: 154,
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TitleMediumText(
                    title:
                        "${_sdController.config?.currentTerm ?? ''} Overview",
                  ),
                  DataNumber(
                    number: totalLogs.toString(),
                    description: "Total logs",
                  ),
                ],
              ),
              Spacer(),
              circularData(_sdController.absentCount, 'Absent', Colors.red),
              circularData(_sdController.cuttingCount, 'Cutting',
                  Colors.yellow.shade700),
              circularData(_sdController.onTimeCount, 'On-Time', Colors.green),
              circularData(_sdController.lateCount, 'Late', Colors.orange)
            ],
          ),
        ),
        // sampleData: sampleDataAct,
      ),
    );
  }
// Widget _webView() {
//     return WebView(
//       appBarTitle: "Dashboard",
//       selectedWidgetMarker: 0,
//       body: AnimatedBuilder(
//         animation: _sdController,
//         builder: (context, child) {
//           return !_sdController.isAllAttendanceCollected
//               ? Center(
//                   child: CircularProgressIndicator(
//                     strokeWidth: 4,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Theme.of(context).primaryColor, // Customize the color
//                     ),
//                   ),
//                 )
//               : Container(
//                   alignment: Alignment.topCenter,
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: SingleChildScrollView(
//                           child: Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 8.0, right: 8.0, bottom: 8.0),
//                             child: Column(
//                               children: [
//                                 // StudentInfoCard(student: _sdController.student),

//                                 Row(
//                                   children: [
//                                     Flexible(
//                                         flex: 1,
//                                         child: StudentInfoCard(
//                                             user: _sdController.student)),
//                                     Flexible(
//                                       flex: 1,
//                                       child: _overviewCard(5),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 8),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8.0),
//                                   child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Expanded(
//                                         child: _webRecentLogsCard(
//                                           context,
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: _myClassesCard(
//                                           context,
//                                         ),
//                                       ),
//                                       // _myClassesCard(context)
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//         },
//       ),
//     );
//   }
  Widget _mobileOverviewCard(leadingFlex, [flexValue = 1]) {
    return AnimatedBuilder(
      animation: _sdController,
      builder: (context, child) {
        double totalLogs = _sdController.allAttendanceList.length.toDouble();
        return MobileSmallCard(
          isShadow: true,
          sideTitle: "Total logs",
          sideTitleTrailer: totalLogs.toString(),
          title: "Overview",
          child: Row(
            children: [
              circularData(
                  _sdController.absentCount, 'Absent', Colors.red, 32.0),
              circularData(
                  _sdController.cuttingCount, 'Cutting', Colors.yellow, 32.0),
              circularData(
                  _sdController.onTimeCount, 'On-Time', Colors.green, 32.0),
              circularData(_sdController.lateCount, 'Late',
                  Color.fromRGBO(255, 152, 0, 1), 32.0),
            ],
          ),
        );
      },
    );
  }

  Widget circularData(value, description, color, [radius = 40.0]) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircularViewer(
            controller: _sdController,
            value: value,
            maxValue: _sdController.allAttendanceList.length.toDouble(),
            radius: radius,
            textStyle: TextStyle(fontSize: 20),
            color: Color(0xffEEEEEE),
            sliderColor: value == 0 ? Color(0xffEEEEEE) : color,
            unSelectedColor: Color.fromARGB(255, 255, 255, 255),
          ),
          Text(description),
        ],
      ),
    );
  }
}
