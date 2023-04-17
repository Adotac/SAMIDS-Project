// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/model/subjectSchedule_model.dart';

import 'package:samids_web_app/src/widgets/circular_viewer.dart';
import 'package:samids_web_app/src/widgets/custom_list_tile.dart';

import 'package:samids_web_app/src/widgets/student_info_card.dart';

import '../../controllers/data_controller.dart';
import '../../model/attendance_model.dart';

import '../../widgets/card_small.dart';
import '../../widgets/card_small_mobile.dart';
import '../../widgets/data_number.dart';
import '../../widgets/mobile_view.dart';

import 'package:intl/intl.dart';

import '../../widgets/web_view.dart';

// ignore: must_be_immutable
class FacultyDashboard extends StatefulWidget {
  static const routeName = '/student-dashboard';
  final DataController dataController;

  const FacultyDashboard({super.key, required this.dataController});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  DataController get _sdController => widget.dataController;

  // add on init
  @override
  void initState() {
    _sdController.getAttendanceToday();
    _sdController.getAttendanceAll();
    _sdController.getStudentClasses();

    super.initState();
  }

  bool isMobile(BoxConstraints constraints) {
    return (constraints.maxWidth <= 450);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
      if (isMobile(constraints)) {
        return _mobileView();
      }

      return _webView();
    });
  }

  Widget _webView() {
    return AnimatedBuilder(
      animation: _sdController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return WebView(
              appBarTitle: 'Dashboard',
              selectedWidgetMarker: 0,
              body: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GridView.builder(
                        itemCount: _sdController.allAttendanceList.length + 2,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          // crossAxisSpacing: 16.0,
                          // mainAxisSpacing: 16.0,
                          childAspectRatio: constraints.maxWidth /
                              2 / // divide by crossAxisCount
                              256, // height of the _overviewCard
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0) {
                            return StudentInfoCard(
                                user: _sdController.student, isFaculty: true);
                          }
                          if (index == 1) {
                            return StudentInfoCard(user: _sdController.student);
                          } else {
                            return _overviewCard(index - 2, context);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _mobileView() {
    return AnimatedBuilder(
      animation: _sdController,
      builder: (context, child) {
        return MobileView(
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

  void _showAttendanceDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$title   Attendance '),
          content: SizedBox(
            child: Card(
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Expanded(child: Text('Subject')),
                  ),
                  DataColumn(
                    label: Text('Room'),
                  ),
                  DataColumn(
                    label: Text('Time'),
                  ),
                  DataColumn(
                    label: Text('Remarks'),
                  ),
                ],
                rows: _sdController.allAttendanceList
                    .map((attendance) =>
                        _buildDataRowRecentLogs(context, attendance))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildDataRowClasses(BuildContext context, SubjectSchedule schedule) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            schedule.subject?.subjectName ?? 'No subject name',
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
            schedule.day.name,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String getTimeStartEnd(SubjectSchedule? subjectSchedule) {
    final timeStart =
        _sdController.formatTime(subjectSchedule?.timeStart ?? DateTime.now());
    final timeEnd =
        _sdController.formatTime(subjectSchedule?.timeEnd ?? DateTime.now());
    return '$timeStart - $timeEnd';
  }

  DataRow classesSampleDataRow(context) {
    return DataRow(
      cells: <DataCell>[
        DataCell(Text('10:30am - 11:30am ')),
        DataCell(Expanded(
          child: Text(
            textAlign: TextAlign.start,
            '10023 - Programming 1',
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Text(
          'On Going',
          style: TextStyle(color: Colors.green),
        )),
      ],
    );
  }

  Widget _dataTableClasses(context) {
    return DataTable(
      columns: [
        DataColumn(
          label: Expanded(child: Text('Subject')),
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
    );
  }

  Widget _dataTableRecentLogs(context) {
    return DataTable(
      columns: [
        DataColumn(
          label: Expanded(child: Text('Subject')),
        ),
        DataColumn(
          label: Text('Room'),
        ),
        DataColumn(
          label: Text('Time'),
        ),
        DataColumn(
          label: Text('Remarks'),
        ),
      ],
      rows: _sdController.allAttendanceList
          .map((attendance) => _buildDataRowRecentLogs(context, attendance))
          .toList(),
    );
  }

  DataRow _buildDataRowRecentLogs(BuildContext context, Attendance attendance) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            attendance.subjectSchedule?.subject?.subjectName ??
                'No subject name',
            style: TextStyle(fontSize: 14),
          ),
        ),
        DataCell(
          Text(
            attendance.subjectSchedule?.room.toString() ?? 'No subject id',
            style: TextStyle(fontSize: 14),
          ),
        ),
        DataCell(
          Text(
            _sdController.formatTime(_getActualTime(attendance)),
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          _sdController.getStatusText(attendance.remarks.name),
        ),
      ],
    );
  }

  Widget _myClassesCard(context) {
    return Card(
      child: CardSmall(
        title: "Class List",
        isShadow: false,
        child: _dataTableClasses(context),
      ),
    );
  }

  Widget _webRecentLogsCard(context) {
    return Card(
      child: CardSmall(
        title: "Recent Activity",
        isShadow: false,
        child:
            // SizedBox(width: 800, child: Text('No recent activity')),
            _dataTableRecentLogs(context),
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
            subtitle: _sdController.getStatusText(attendance.remarks.name),
            leadingIcon: Icon(getStatusIcon(attendance.remarks),
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

  IconData getStatusIcon(Remarks remarks) {
    switch (remarks) {
      case Remarks.onTime:
        return Icons.timer_outlined;
      case Remarks.late:
        return Icons.schedule_outlined;
      case Remarks.cutting:
        return Icons.cancel_outlined;
      case Remarks.absent:
        return Icons.highlight_off_outlined;
    }
  }

  void _showMyClassesDialog(BuildContext context, title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$title   Class List '),
          content: _dataTableClasses(context),
        );
      },
    );
  }

  String getSubjectName(attendance) {
    return attendance.subjectSchedule?.subject?.subjectName ?? 'No Subject';
  }

  Widget _overviewCard(index, BuildContext context) {
    Attendance attendance = _sdController.allAttendanceList[index];
    double totalLogs = _sdController.allAttendanceList.length.toDouble();
    return StatefulBuilder(builder: (context, setState) {
      return SizedBox(
        child: Card(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getSubjectName(attendance),
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        _showMyClassesDialog(
                            context,
                            attendance.subjectSchedule?.subject?.subjectName ??
                                'No Subject');
                      },
                      child: Text('Class List'),
                    ),
                    TextButton(
                      onPressed: () {
                        _showAttendanceDialog(
                            context,
                            attendance.subjectSchedule?.subject?.subjectName ??
                                'No Subject');
                      },
                      child: Text('Attendance List'),
                    ),
                    TextButton(
                      onPressed: () {
                        showCancelClassDialog(context);
                      },
                      child: Text(
                        'Cancel Class',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Code:'),
                                Text('Time:'),
                                Text('Dates:'),
                              ],
                            ),
                            SizedBox(width: 8.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(attendance.subjectSchedule?.room
                                        .toString() ??
                                    'No Room'), // Replace with actual class room code
                                Text(
                                  getTimeStartEnd(attendance.subjectSchedule),
                                ),
                                Text('${attendance.subjectSchedule?.day.name}'),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 6.0),
                        DataNumber(
                          number: totalLogs.toString(),
                          description: "Total logs",
                        ),
                      ],
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              circularData(_sdController.absentCount, 'Absent',
                                  Colors.red),
                              circularData(_sdController.cuttingCount,
                                  'Cutting', Colors.yellow.shade700),
                              circularData(_sdController.onTimeCount, 'On-Time',
                                  Colors.green),
                              circularData(_sdController.lateCount, 'Late',
                                  Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> showCancelClassDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _textFieldController = TextEditingController();
        return AlertDialog(
          title: Text('Cancel Class'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(
              hintText: 'Enter reason for cancellation',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                // TODO: Implement cancel class functionality
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
//                                       child: _overviewCard(5,context),
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

  Widget circularData(value, description, color, [radius = 40.0]) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircularViewer(
            value: value,
            maxValue: _sdController.allAttendanceList.length.toDouble(),
            radius: radius,
            textStyle: TextStyle(fontSize: 20),
            color: Color(0xffEEEEEE),
            sliderColor: color,
            unSelectedColor: Color.fromARGB(255, 255, 255, 255),
          ),
          SizedBox(
            height: 4.0,
          ),
          Text(description),
        ],
      ),
    );
  }
}
