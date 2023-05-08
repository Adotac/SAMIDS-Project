// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/model/subjectSchedule_model.dart';

import 'package:samids_web_app/src/widgets/circular_viewer.dart';
import 'package:samids_web_app/src/widgets/custom_list_tile.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:samids_web_app/src/widgets/student_info_card.dart';

import '../../model/attendance_model.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../model/student_model.dart';
import '../../widgets/card_small.dart';
import '../../widgets/card_small_mobile.dart';
import '../../widgets/data_number.dart';
import '../../widgets/line_chart.dart';
import '../../widgets/mobile_view.dart';
import 'package:intl/intl.dart';

import '../../widgets/web_view.dart';
import '../page_size_constriant.dart';
import 'attendance_list.dart';
import 'class_list.dart';

// ignore: must_be_immutable
class FacultyDashboard extends StatefulWidget {
  static const routeName = '/faculty-dashboard';
  final FacultyController dataController;

  const FacultyDashboard({super.key, required this.dataController});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  FacultyController get _dataController => widget.dataController;

  // add on init
  @override
  void initState() {
    _dataController.getConfig();
    _dataController.getAttendanceAll(null);
    _dataController.getFacultyClasses();

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
      animation: _dataController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return WebView(
              facultyController: _dataController,
              appBarTitle: 'Dashboard',
              selectedWidgetMarker: 0,
              body: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildListView()),
                    Expanded(child: _chartInfo()),
                    // Expanded(
                    //     child: Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    //   child: _buildGridView(constraints),
                    // )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _chartInfo() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Card(
                child: SizedBox(
                  height: 427,
                  child: Column(
                    children: [
                      StudentInfoCard(
                          course: "Faculty",
                          id: _dataController.faculty.facultyNo,
                          firstName: _dataController.faculty.firstName,
                          lastName: _dataController.faculty.lastName,
                          isFaculty: true),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              _buildLegendContainer(Colors.red, 16, 'Absent'),
                              SizedBox(width: 8),
                              _buildLegendContainer(
                                  Colors.yellow.shade700, 16, 'Cutting'),
                              SizedBox(width: 8),
                              _buildLegendContainer(
                                  Colors.green, 16, 'On-Time'),
                              SizedBox(width: 8),
                              _buildLegendContainer(Colors.orange, 16, 'Late'),
                            ],
                          ),
                          Text(
                            _getCurrentYearTerm(),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (_dataController.isRemarksCountListLoading)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 150,
                            ),
                            Text("No data available"),
                          ],
                        )
                      else if (_dataController.remarksCountList.length <= 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 150,
                            ),
                            Text("Insufficient data for chart"),
                          ],
                        )
                      else
                        SizedBox(
                          height: 232,
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: DashboardLineChart(
                            isShowingMainData: false,
                            facultyController: _dataController,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _myScheduleClass(),
        ],
      ),
    );
  }

  Widget mobileBody() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dashboard',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _dataController.config?.currentTerm ?? 'Term',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendContainer(Colors.red, 16, 'Absent'),
                      SizedBox(width: 8),
                      _buildLegendContainer(
                          Colors.yellow.shade700, 16, 'Cutting'),
                      SizedBox(width: 8),
                      _buildLegendContainer(Colors.green, 16, 'On-Time'),
                      SizedBox(width: 8),
                      _buildLegendContainer(Colors.orange, 16, 'Late'),
                    ],
                  ),
                  if (_dataController.isRemarksCountListLoading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 150,
                        ),
                        Text("No data available"),
                      ],
                    )
                  else
                    SizedBox(
                      height: 232,
                      child: DashboardLineChart(
                        isShowingMainData: false,
                        facultyController: _dataController,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: List<Widget>.generate(
                  _dataController.facultyClasses.length, (int index) {
                return _overviewCard(index, context);
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegendContainer(Color color, double width, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget buildLineChart(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: false),
              minX: 0,
              maxX: 3,
              minY: 0,
              maxY: 4,
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(0, _dataController.absentCount.toDouble()),
                    FlSpot(1, _dataController.cuttingCount.toDouble()),
                    FlSpot(2, _dataController.onTimeCount.toDouble()),
                    FlSpot(3, _dataController.lateCount.toDouble()),
                  ],
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: Colors.blue, // Use a single color for the line
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobileView() {
    return AnimatedBuilder(
      animation: _dataController,
      builder: (context, child) {
        return MobileView(
            routeName: FacultyDashboard.routeName,
            currentIndex: 0,
            appBarTitle: 'Dashboard',
            userName:
                '${_dataController.faculty.firstName} ${_dataController.faculty.lastName}',
            body: [
              mobileBody(),
            ]);

        // body: _sdController.isCountCalculated
        //     ? [_mobileOverviewCard(2, 0), _mobileRecentLogsCard()]
        //     : [
        //         Center(
        //           child: CircularProgressIndicator(
        //             strokeWidth: 4,
        //             valueColor: AlwaysStoppedAnimation<Color>(
        //               Theme.of(context).primaryColor, // Customize the color
        //             ),
        //           ),
        //         ),
        //       ]);
      },
    );
  }

  void _showAttendanceDialog(
      BuildContext context, int subjectId, String title, int schedId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: _dataController,
          builder: (context, child) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$title - Attendance List'),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () async {
                            await _dataController.downloadAttendanceBySchedId(
                                context, schedId, title, subjectId);
                          },
                          child: Text("Download Table")),
                    ],
                  ),
                ],
              ),
              content: SizedBox(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Text('First Name'),
                      ),
                      DataColumn(
                        label: Text('Last Name'),
                      ),
                      DataColumn(
                        label: Text('Date'),
                      ),
                      DataColumn(
                        label: Text('Time In'),
                      ),
                      DataColumn(
                        label: Text('Time out'),
                      ),
                      DataColumn(
                        label: Text('Remarks'),
                      ),
                    ],
                    rows: _dataController.attendanceBySchedId[schedId]!
                        .map((attendance) =>
                            _buildAttendanceList(context, attendance))
                        .toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String getTimeStartEnd(SubjectSchedule? subjectSchedule) {
    final timeStart = _dataController
        .formatTime(subjectSchedule?.timeStart ?? DateTime.now());
    final timeEnd =
        _dataController.formatTime(subjectSchedule?.timeEnd ?? DateTime.now());
    return '$timeStart - $timeEnd';
  }

  DataRow _buildDataRowClassList(BuildContext context, Student student) {
    return DataRow(
      cells: [
        _tableDataCell(student.studentNo.toString()),
        _tableDataCell(student.firstName),
        _tableDataCell(student.lastName),
        _tableDataCell(student.year.name),
        _tableDataCell(student.course),
      ],
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

  DataColumn _customDataColumn({required Widget label, int flex = 1}) {
    return DataColumn(
      label: Expanded(
        flex: flex,
        child: label,
      ),
    );
  }

  DataRow _buildAttendanceList(BuildContext context, Attendance attendance) {
    return DataRow(
      cells: [
        // _tableDataCell(attendance.attendanceId.toString()),
        _tableDataCell(attendance.student?.firstName ?? 'No First Name'),
        _tableDataCell(attendance.student?.lastName ?? 'No Last Name'),
        _tableDataCell(_formatDate(attendance.date!)),
        _tableDataCell(attendance.actualTimeIn != null
            ? _dataController.formatTime(attendance.actualTimeIn!)
            : 'No Time In'),
        _tableDataCell(attendance.actualTimeOut != null
            ? _dataController.formatTime(attendance.actualTimeOut!)
            : 'No Time Out'),
        DataCell(
          _dataController.getStatusText(attendance.remarks?.name ?? 'Pending'),
        ),
      ],
    );
  }

  _tableDataCell(String text) {
    return DataCell(
      Text(
        text,
        style: TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _myScheduleClass() {
    return Card(
        child: Container(
      // width: MediaQuery.of(context).size.width * 0.4,
      width: double.infinity,
      // height: 445,
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject Schedule',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // SizedBox(height: 8),
            // Text(
            //   _getCurrentYearTerm(),
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: Colors.grey,
            //   ),
            // ),
            SizedBox(height: 16),
            SizedBox(width: double.infinity, child: _dataTableClasses(context)),
          ],
        ),
      ),
    ));
  }

  String _getCurrentYearTerm() {
    String currentTerm = _dataController.config?.currentTerm ?? '';
    String currentYear = _dataController.config?.currentYear ?? '';

    return '$currentTerm - $currentYear';
  }

  String _formatCurrentDate() {
    return DateFormat('MMMM d, y').format(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  DateTime _getActualTime(Attendance attendance) =>
      attendance.actualTimeOut != null
          ? attendance.actualTimeOut!
          : attendance.actualTimeIn != null
              ? attendance.actualTimeIn!
              : DateTime.now();

  IconData getStatusIcon(Remarks remarks) {
    return Icons.timer_outlined;
  }

  void _showMyClassesDialog(
      BuildContext context, subjectId, title, int schedId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: _dataController,
          builder: (context, _) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$title - Class List'),
                  TextButton(
                      onPressed: () async {
                        await _dataController.downloadClassListSchedId(
                            context, schedId, title, subjectId);
                      },
                      child: Text("Download Table")),
                ],
              ),
              content: SingleChildScrollView(
                child: _dataTableClassList(context, schedId),
              ),
            );
          },
        );
      },
    );
  }

  String getSubjectName(attendance) {
    return attendance.subjectSchedule?.subject?.subjectName ?? 'No Subject';
  }

  Widget _overviewCard(index, BuildContext context) {
    SubjectSchedule subjectSchedule = _dataController.facultyClasses[index];
    int schedId = subjectSchedule.schedId;
    double totalLogs =
        _dataController.attendanceBySchedId[schedId]?.length.toDouble() ?? 0.0;

    Map<Remarks, int> remarksCount =
        _dataController.remarksBySchedId[schedId] ?? {};

    return StatefulBuilder(builder: (context, setState) {
      if (!_dataController.isRemarksCountBySchedId) {
        return Center(child: CircularProgressIndicator());
      }

      return SizedBox(
        child: Card(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildOverviewCard(
                  remarksCount, subjectSchedule, context, totalLogs),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildOverviewCard(Map<Remarks, int> remarksCount,
      SubjectSchedule subjectSchedule, BuildContext context, double totalLogs) {
    return [
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double fontSize = constraints.maxWidth <= 450 ? 16 : 24;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //web
              if (constraints.maxWidth >= 450)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${subjectSchedule.schedId} - ${subjectSchedule.subject?.subjectName ?? 'No subject name'}",
                      style: TextStyle(
                          fontSize: fontSize, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        _dataController.getStudentListbySchedId(
                            subjectSchedule.subject?.subjectID ?? 0);
                        _showMyClassesDialog(
                          context,
                          subjectSchedule.schedId,
                          subjectSchedule.subject?.subjectName ?? 'No Subject',
                          subjectSchedule.schedId,
                        );
                      },
                      child: Text('Class List'),
                    ),
                    const SizedBox(width: 4.0),
                    TextButton(
                      onPressed: () {
                        _showAttendanceDialog(
                            context,
                            subjectSchedule.schedId,
                            subjectSchedule.subject?.subjectName ??
                                'No Subject',
                            subjectSchedule.schedId);
                      },
                      child: Text('Attendance'),
                    ),
                  ],
                ),
              //mobile
              if (constraints.maxWidth < 450)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subjectSchedule.subject?.subjectName ?? 'No Subject',
                      style: TextStyle(
                          fontSize: fontSize, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            _dataController.getStudentListbySchedId(
                                subjectSchedule.subject?.subjectID ?? 0);
                            // _dataController.downloadClassListSchedId(
                            //     context,
                            //     subjectSchedule.schedId,
                            //     subjectSchedule.subject?.subjectName ??
                            //         'No Subject',
                            //     subjectSchedule.schedId);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FacultySubjectClassList(
                                  subjectId: subjectSchedule.schedId.toString(),
                                  title: subjectSchedule.subject?.subjectName ??
                                      'No Subject',
                                  dataController: _dataController,
                                  schedId: subjectSchedule.schedId,
                                ),
                              ),
                            );
                          },
                          child: Text('Class List'),
                        ),
                        const SizedBox(width: 4.0),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FacultySubjectAttendanceList(
                                  subjectId: subjectSchedule.schedId.toString(),
                                  title: subjectSchedule.subject?.subjectName ??
                                      'No Subject',
                                  dataController: _dataController,
                                  schedId: subjectSchedule.schedId,
                                ),
                              ),
                            );
                          },
                          child: Text('Attendance List'),
                        ),
                      ],
                    )
                  ],
                ),
              SizedBox(height: constraints.maxWidth >= 450 ? 18.0 : 0),
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
                              Text('Date:'),
                              Text('Time:'),
                              Text('Room:'),
                            ],
                          ),
                          SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _dataController.buildNearestDateRow(
                                context,
                                subjectSchedule.day,
                              ),
                              Text(
                                  '${DateFormat('hh:mm a').format(subjectSchedule.timeStart)} - ${DateFormat('hh:mm a').format(subjectSchedule.timeEnd)}'),
                              Text(subjectSchedule.room.toString()),
                            ],
                          ),
                        ],
                      ),
                      Visibility(
                        visible: constraints.maxWidth < 450,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                circularData(
                                  remarksCount[Remarks.absent] ?? 0,
                                  'Absent',
                                  Colors.red,
                                  totalLogs,
                                ),
                                circularData(
                                  remarksCount[Remarks.cutting] ?? 0,
                                  'Cutting',
                                  Colors.yellow.shade700,
                                  totalLogs,
                                ),
                                circularData(
                                  remarksCount[Remarks.onTime] ?? 0,
                                  'On-Time',
                                  Colors.green,
                                  totalLogs,
                                ),
                                circularData(
                                  remarksCount[Remarks.late] ?? 0,
                                  'Late',
                                  Colors.orange,
                                  totalLogs,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: constraints.maxWidth >= 450 ? 18.0 : 0),
                      DataNumber(
                        number: totalLogs.toString(),
                        description: "Logs",
                      ),
                    ],
                  ),
                  Visibility(
                    visible: constraints.maxWidth >= 450,
                    child: Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              circularData(
                                remarksCount[Remarks.absent] ?? 0,
                                'Absent',
                                Colors.red,
                                totalLogs,
                              ),
                              circularData(
                                remarksCount[Remarks.cutting] ?? 0,
                                'Cutting',
                                Colors.yellow.shade700,
                                totalLogs,
                              ),
                              circularData(
                                remarksCount[Remarks.onTime] ?? 0,
                                'On-Time',
                                Colors.green,
                                totalLogs,
                              ),
                              circularData(
                                remarksCount[Remarks.late] ?? 0,
                                'Late',
                                Colors.orange,
                                totalLogs,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 16.0),
            ],
          );
        },
      ),
    ];
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

  Widget circularData(value, description, color, [maxValue]) {
    maxValue ??= _dataController.allAttendanceList.length.toDouble();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double radius = 40.0;
        if (MediaQuery.of(context).size.width <= 450) {
          radius = 33.0;
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CircularViewer(
                controller: _dataController,
                value: value,
                maxValue: maxValue,
                radius: radius,
                textStyle: TextStyle(fontSize: 20),
                color: Color(0xffEEEEEE),
                sliderColor: value == 0 ? Color(0xffEEEEEE) : color,
                unSelectedColor: Color.fromARGB(255, 255, 255, 255),
              ),
              SizedBox(
                height: 4.0,
              ),
              Text(description),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> sampleStudentClasses = [
    {
      'subject': 'Data Structures and Algorithms',
      'room': 'BCL1',
      'timeStart': DateTime(2023, 4, 1, 5, 30),
      'timeEnd': DateTime(2023, 4, 1, 6, 30),
      'day': 'Mon, Wed, Fri',
    },
    {
      'subject': 'Operating Systems',
      'room': 'BCL2',
      'timeStart': DateTime(2023, 4, 1, 10, 0),
      'timeEnd': DateTime(2023, 4, 1, 11, 30),
      'day': 'Tue, Thu',
    },
    {
      'subject': 'Design and Analysis of Algorithms',
      'room': 'BCL3',
      'timeStart': DateTime(2023, 4, 1, 2, 0),
      'timeEnd': DateTime(2023, 4, 1, 3, 30),
      'day': 'Mon, Wed, Fri',
    },
    {
      'subject': 'Natural Language Processing',
      'room': 'BCL4',
      'timeStart': DateTime(2023, 4, 1, 13, 0),
      'timeEnd': DateTime(2023, 4, 1, 14, 30),
      'day': 'Tue, Thu',
    },
    {
      'subject': 'Programming Languages',
      'room': 'BCL5',
      'timeStart': DateTime(2023, 4, 1, 16, 0),
      'timeEnd': DateTime(2023, 4, 1, 17, 30),
      'day': 'Mon, Wed, Fri',
    },
    // {
    //   'subject': 'Calculus',
    //   'room': 'BCL6',
    //   'timeStart': DateTime(2023, 4, 1, 8, 0),
    //   'timeEnd': DateTime(2023, 4, 1, 9, 30),
    //   'day': 'Tue, Thu',
    // },
    {
      'subject': 'Machine Learning',
      'room': 'BCL7',
      'timeStart': DateTime(2023, 4, 1, 14, 30),
      'timeEnd': DateTime(2023, 4, 1, 16, 0),
      'day': 'Mon, Wed, Fri',
    },
    // {
    //   'subject': 'Apps Development 2',
    //   'room': 'BCL8',
    //   'timeStart': DateTime(2023, 4, 1, 9, 0),
    //   'timeEnd': DateTime(2023, 4, 1, 10, 30),
    //   'day': 'Tue, Thu',
    // },
    // {
    //   'subject': 'Software Engineering 2',
    //   'room': 'BCL9',
    //   'timeStart': DateTime(2023, 4, 1, 11, 0),
    //   'timeEnd': DateTime(2023, 4, 1, 12, 30),
    //   'day': 'Mon, Wed, Fri',
    // },
  ];

  Widget _dataTableClassList(context, int schedId) {
    // if (_dataController.isGetStudentListByLoading) {
    //   return Center(child: CircularProgressIndicator());
    // }

    return DataTable(
      columns: [
        _customDataColumn(label: Text('Student No.'), flex: 3),
        _customDataColumn(label: Text('First Name'), flex: 1),
        _customDataColumn(label: Text('Last Name'), flex: 1),
        _customDataColumn(label: Text('Year'), flex: 1),
        _customDataColumn(label: Text('Course'), flex: 1),
      ],
      rows: _dataController.students
          .map((student) => _buildDataRowClassList(context, student))
          .toList(),
    );
  }

  Widget _dataTableClasses(context) {
    return DataTable(
      columns: [
        _customDataColumn(label: Text('Subject'), flex: 3),
        _customDataColumn(label: Text('Room'), flex: 1),
        _customDataColumn(label: Text('Time'), flex: 1),
        _customDataColumn(label: Text('Day'), flex: 1),
      ],
      rows: _dataController.facultyClasses
          .map((attendance) => _buildDataRowClasses(context, attendance))
          .toList(),
    );
  }

  ListView _buildListView() {
    return ListView.builder(
      itemCount: _dataController.facultyClasses.length,
      itemBuilder: (BuildContext context, int index) {
        // return Text('asdf');
        return _overviewCard(index, context);
      },
    );
  }
}
