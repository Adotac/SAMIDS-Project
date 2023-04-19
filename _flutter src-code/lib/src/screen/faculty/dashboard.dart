// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/model/subjectSchedule_model.dart';

import 'package:samids_web_app/src/widgets/circular_viewer.dart';
import 'package:samids_web_app/src/widgets/custom_list_tile.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:samids_web_app/src/widgets/student_info_card.dart';

import '../../controllers/data_controller.dart';
import '../../model/attendance_model.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../widgets/card_small.dart';
import '../../widgets/card_small_mobile.dart';
import '../../widgets/data_number.dart';
import '../../widgets/line_chart.dart';
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Card(
                                  child: Column(
                                    children: [
                                      StudentInfoCard(
                                          user: _sdController.student,
                                          isFaculty: true),
                                      SizedBox(
                                        height: 80,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _buildLegendContainer(
                                              Colors.red, 16, 'Absent'),
                                          SizedBox(width: 8),
                                          _buildLegendContainer(
                                              Colors.yellow.shade700,
                                              16,
                                              'Cutting'),
                                          SizedBox(width: 8),
                                          _buildLegendContainer(
                                              Colors.green, 16, 'On-Time'),
                                          SizedBox(width: 8),
                                          _buildLegendContainer(
                                              Colors.orange, 16, 'Late'),
                                        ],
                                      ),
                                      SizedBox(
                                          height: 240,
                                          child: TestLineChart(
                                              isShowingMainData: false)),
                                    ],
                                  ),
                                ),

                                // SizedBox(
                                //     height: 250,
                                //     child: TestLineChart(
                                //         isShowingMainData: false)),
                                // StudentInfoCard(
                                //     user: _sdController.student,
                                //     isFaculty: true),
                                // buildLineChart(context),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _myScheduleClass(),
                          )
                        ],
                      )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: _buildGridView(constraints),
                  )),
                ],
              ),
            );
          },
        );
      },
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
  // GridView _buildGridView(BoxConstraints constraints) {
  //   return GridView.builder(
  //     itemCount: _sdController.allAttendanceList.length,
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       // crossAxisSpacing: 16.0,
  //       // mainAxisSpacing: 16.0,
  //       childAspectRatio: constraints.maxWidth /
  //           2 / // divide by crossAxisCount
  //           256, // height of the _overviewCard
  //     ),
  //     itemBuilder: (BuildContext context, int index) {
  //       return _overviewCard(index, context);
  //     },
  //   );
  // }

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
                    FlSpot(0, _sdController.absentCount.toDouble()),
                    FlSpot(1, _sdController.cuttingCount.toDouble()),
                    FlSpot(2, _sdController.onTimeCount.toDouble()),
                    FlSpot(3, _sdController.lateCount.toDouble()),
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
      animation: _sdController,
      builder: (context, child) {
        return MobileView(
            currentIndex: 0,
            appBarTitle: 'Dashboard',
            userName:
                '${_sdController.student.firstName} ${_sdController.student.lastName}',
            body: _sdController.isCountCalculated
                ? [_mobileOverviewCard(2, 0), _mobileRecentLogsCard()]
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

  // Widget _dataTableClasses(context) {
  //   return DataTable(
  //     columns: [
  //       customDataColumn(label: Text('Subject'), flex: 3),
  //       customDataColumn(label: Text('Room'), flex: 1),
  //       customDataColumn(label: Text('Time'), flex: 1),
  //       customDataColumn(label: Text('Day'), flex: 1),
  //     ],
  //     rows: _sdController.studentClasses
  //         .map((attendance) => _buildDataRowClasses(context, attendance))
  //         .toList(),
  //   );
  // }

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

  DataColumn customDataColumn({required Widget label, int flex = 1}) {
    return DataColumn(
      label: Expanded(
        flex: flex,
        child: label,
      ),
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

  Widget _myScheduleClass() {
    return Card(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject Schedule',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '1st Semester - 2023',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(width: double.infinity, child: _dataTableClasses(context)),
        ],
      ),
    ));
  }

  String _formatCurrentDate() {
    return DateFormat('MMMM d, y').format(DateTime.now());
  }

  List<Map<String, dynamic>> sampleRecentLogsData = [
    {
      'subjectName': 'Data Structures',
      'statusText': 'On Time',
      'statusIcon': Icons.timer_outlined,
      'statusColor': Colors.green,
      'time': DateTime(2023, 4, 12, 9, 30),
      'roomId': 'BCL1',
    },
    {
      'subjectName': 'Algorithms',
      'statusText': 'Late',
      'statusIcon': Icons.access_time,
      'statusColor': Colors.orange,
      'time': DateTime(2023, 4, 12, 11, 15),
      'roomId': 'BCL2',
    },
    {
      'subjectName': 'Computer Networks',
      'statusText': 'Absent',
      'statusIcon': Icons.access_time,
      'statusColor': Colors.red,
      'time': DateTime(2023, 4, 11, 14, 0),
      'roomId': 'BCL3',
    },
    {
      'subjectName': 'Database Systems',
      'statusText': 'On Time',
      'statusIcon': Icons.timer_outlined,
      'statusColor': Colors.green,
      'time': DateTime(2023, 4, 11, 16, 30),
      'roomId': 'BCL4',
    },
    {
      'subjectName': 'Operating Systems',
      'statusText': 'Late',
      'statusIcon': Icons.access_time,
      'statusColor': Colors.orange,
      'time': DateTime(2023, 4, 10, 10, 45),
      'roomId': 'BCL5',
    },
    {
      'subjectName': 'Software Engineering',
      'statusText': 'Cutting',
      'statusIcon': Icons.access_time,
      'statusColor': Colors.yellow.shade700,
      'time': DateTime(2023, 4, 10, 13, 15),
      'roomId': 'BCL6',
    },
    {
      'subjectName': 'Artificial Intelligence',
      'statusText': 'On Time',
      'statusIcon': Icons.timer_outlined,
      'statusColor': Colors.green,
      'time': DateTime(2023, 4, 9, 9, 0),
      'roomId': 'BCL7',
    },
    {
      'subjectName': 'Machine Learning',
      'statusText': 'Late',
      'statusIcon': Icons.access_time,
      'statusColor': Colors.orange,
      'time': DateTime(2023, 4, 9, 15, 45),
      'roomId': 'BCL8',
    },
  ];

  // Widget _mobileRecentLogsCard() {
  //   return MobileSmallCard(
  //     isShadow: false,
  //     sideTitle: _formatCurrentDate(),
  //     title: "Recent Activity",
  //     child: ListView.builder(
  //       shrinkWrap: true,
  //       itemCount: _sdController.attendance.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         Attendance attendance = _sdController.attendance[index];
  //         return CustomListTile(
  //           title: attendance.subjectSchedule?.subject?.subjectName ??
  //               'No subject name',
  //           subtitle: _sdController.getStatusText(attendance.remarks.name),
  //           leadingIcon: Icon(getStatusIcon(attendance.remarks),
  //               color: Theme.of(context).scaffoldBackgroundColor),
  //           leadingColors:
  //               _sdController.getStatusColor(attendance.remarks, context),
  //           trailingText: _sdController.formatTime(_getActualTime(attendance)),
  //           subTrailingText:
  //               attendance.subjectSchedule?.room.toString() ?? 'No subject id',
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _mobileRecentLogsCard() {
    return MobileSmallCard(
      isShadow: false,
      sideTitle: _formatCurrentDate(),
      title: "Recent Activity",
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: sampleRecentLogsData.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, dynamic> attendance = sampleRecentLogsData[index];
          return CustomListTile(
            title: attendance['subjectName'],
            subtitle: Text(attendance['statusText'],
                style:
                    TextStyle(color: attendance['statusColor'], fontSize: 14)),
            leadingIcon: Icon(
              attendance['statusIcon'],
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            leadingColors: attendance['statusColor'],
            trailingText: _sdController.formatTime(attendance['time']),
            subTrailingText: attendance['roomId'],
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
      case Remarks.cutting:

      case Remarks.absent:
        return Icons.schedule_outlined;
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

  // Widget _overviewCard(index, BuildContext context) {
  //   Attendance attendance = _sdController.allAttendanceList[index];
  //   double totalLogs = _sdController.allAttendanceList.length.toDouble();
  //   return StatefulBuilder(builder: (context, setState) {
  //     return SizedBox(
  //       child: Card(
  //         child: Container(
  //           padding: EdgeInsets.all(16.0),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: _buildOverviewCard(attendance, context, totalLogs),
  //           ),
  //         ),
  //       ),
  //     );
  //   });
  // }
  List<Widget> _buildOverviewCard(
      Map<String, dynamic> attendance, BuildContext context, double totalLogs) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            attendance['subjectName'],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          TextButton(
            onPressed: () {
              _showMyClassesDialog(context, attendance['subjectName']);
            },
            child: Text('Class List'),
          ),
          TextButton(
            onPressed: () {
              _showAttendanceDialog(context, attendance['subjectName']);
            },
            child: Text('Attendance List'),
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
                      Text(attendance['room']),
                      Text(
                        DateFormat('hh:mm a').format(attendance['timeStart']) +
                            ' - ' +
                            DateFormat('hh:mm a').format(attendance['timeEnd']),
                      ),
                      Text(attendance['day']),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.0),
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
                    circularData(attendance['absentCount'], 'Absent',
                        Colors.red, totalLogs),
                    circularData(attendance['cuttingCount'], 'Cutting',
                        Colors.yellow.shade700, totalLogs),
                    circularData(attendance['onTimeCount'], 'On-Time',
                        Colors.green, totalLogs),
                    circularData(attendance['lateCount'], 'Late', Colors.orange,
                        totalLogs),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      SizedBox(height: 16.0),
    ];
  }

  // List<Widget> _buildOverviewCard(Map<String, dynamic> attendance, BuildContext context, double totalLogs) {
  //   return [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   getSubjectName(attendance),
  //                   style:
  //                       TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //                 ),
  //                 Spacer(),
  //                 TextButton(
  //                   onPressed: () {
  //                     _showMyClassesDialog(
  //                         context,
  //                         attendance.subjectSchedule?.subject?.subjectName ??
  //                             'No Subject');
  //                   },
  //                   child: Text('Class List'),
  //                 ),
  //                 TextButton(
  //                   onPressed: () {
  //                     _showAttendanceDialog(
  //                         context,
  //                         attendance.subjectSchedule?.subject?.subjectName ??
  //                             'No Subject');
  //                   },
  //                   child: Text('Attendance List'),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 8.0),
  //             Row(
  //               children: [
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           children: [
  //                             Text('Code:'),
  //                             Text('Time:'),
  //                             Text('Dates:'),
  //                           ],
  //                         ),
  //                         SizedBox(width: 8.0),
  //                         Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           children: [
  //                             Text(attendance.subjectSchedule?.room
  //                                     .toString() ??
  //                                 'No Room'), // Replace with actual class room code
  //                             Text(
  //                               getTimeStartEnd(attendance.subjectSchedule),
  //                             ),
  //                             Text('${attendance.subjectSchedule?.day.name}'),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: 6.0),
  //                     DataNumber(
  //                       number: totalLogs.toString(),
  //                       description: "Total logs",
  //                     ),
  //                   ],
  //                 ),
  //                 Expanded(
  //                   child: Row(
  //                     crossAxisAlignment: CrossAxisAlignment.end,
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           circularData(_sdController.absentCount, 'Absent',
  //                               Colors.red),
  //                           circularData(_sdController.cuttingCount,
  //                               'Cutting', Colors.yellow.shade700),
  //                           circularData(_sdController.onTimeCount, 'On-Time',
  //                               Colors.green),
  //                           circularData(_sdController.lateCount, 'Late',
  //                               Colors.orange),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 )
  //               ],
  //             ),
  //             SizedBox(height: 16.0),
  //           ];
  // }

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
          sideTitleTrailer: "19",
          title: "Overview",
          child: Row(
            children: [
              circularData(2, 'Absent', Colors.red, 19),
              circularData(2, 'Cutting', Colors.yellow, 19),
              circularData(12, 'On-Time', Colors.green, 19),
              circularData(3, 'Late', Color.fromRGBO(255, 152, 0, 1), 19),
            ],
          ),
        );
      },
    );
  }

  Widget circularData(value, description, color, [maxValue]) {
    maxValue ??= _sdController.allAttendanceList.length.toDouble();
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
                value: value,
                maxValue: maxValue,
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

  List<DataRow> _buildSampleDataRows(BuildContext context) {
    return sampleStudentClasses.map((schedule) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              schedule['subject'],
              style: TextStyle(fontSize: 14),
            ),
          ),
          DataCell(
            Text(
              schedule['room'],
              style: TextStyle(fontSize: 14),
            ),
          ),
          DataCell(
            Text(
              '${schedule['timeStart'].hour == 0 ? 12 : (schedule['timeStart'].hour < 13 ? schedule['timeStart'].hour : schedule['timeStart'].hour - 12).toString().padLeft(2, '0')}:${schedule['timeStart'].minute.toString().padLeft(2, '0')} ${schedule['timeStart'].hour < 12 ? 'AM' : 'PM'} - ${(schedule['timeEnd'].hour == 0 ? 12 : (schedule['timeEnd'].hour < 13 ? schedule['timeEnd'].hour : schedule['timeEnd'].hour - 12)).toString().padLeft(2, '0')}:${schedule['timeEnd'].minute.toString().padLeft(2, '0')} ${schedule['timeEnd'].hour < 12 ? 'AM' : 'PM'}',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          DataCell(
            Text(
              schedule['day'],
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _dataTableClasses(context) {
    return DataTable(
      columns: [
        customDataColumn(label: Text('Subject'), flex: 3),
        customDataColumn(label: Text('Room'), flex: 1),
        customDataColumn(label: Text('Time'), flex: 1),
        customDataColumn(label: Text('Day'), flex: 1),
      ],
      rows: _buildSampleDataRows(context),
    );
  }

  List<Map<String, dynamic>> sampleOverviewData = [
    {
      'subjectName': 'Data Structures and Algorithms',
      'room': 'BCL1',
      'timeStart': DateTime(2023, 4, 1, 5, 30),
      'timeEnd': DateTime(2023, 4, 1, 6, 30),
      'day': 'Mon, Wed, Fri',
      'absentCount': 2,
      'cuttingCount': 10,
      'onTimeCount': 5,
      'lateCount': 15,
    },
    {
      'subjectName': 'Operating Systems',
      'room': 'BCL2',
      'timeStart': DateTime(2023, 4, 1, 10, 0),
      'timeEnd': DateTime(2023, 4, 1, 11, 30),
      'day': 'Tue, Thu',
      'absentCount': 0,
      'cuttingCount': 5,
      'onTimeCount': 20,
      'lateCount': 10,
    },
    {
      'subjectName': 'Design and Analysis of Algorithms',
      'room': 'BCL3',
      'timeStart': DateTime(2023, 4, 1, 2, 0),
      'timeEnd': DateTime(2023, 4, 1, 3, 30),
      'day': 'Mon, Wed, Fri',
      'absentCount': 7,
      'cuttingCount': 5,
      'onTimeCount': 5,
      'lateCount': 10,
    },
    {
      'subjectName': 'Natural Language Processing',
      'room': 'BCL4',
      'timeStart': DateTime(2023, 4, 1, 13, 0),
      'timeEnd': DateTime(2023, 4, 1, 14, 30),
      'day': 'Tue, Thu',
      'absentCount': 2,
      'cuttingCount': 15,
      'onTimeCount': 10,
      'lateCount': 10,
    },
    {
      'subjectName': 'Programming Languages',
      'room': 'BCL5',
      'timeStart': DateTime(2023, 4, 1, 16, 0),
      'timeEnd': DateTime(2023, 4, 1, 17, 30),
      'day': 'Mon, Wed, Fri',
      'absentCount': 3,
      'cuttingCount': 5,
      'onTimeCount': 10,
      'lateCount': 15,
    },
    {
      'subjectName': 'Machine Learning',
      'room': 'BCL7',
      'timeStart': DateTime(2023, 4, 1, 14, 30),
      'timeEnd': DateTime(2023, 4, 1, 16, 0),
      'day': 'Mon, Wed, Fri',
      'absentCount': 0,
      'cuttingCount': 10,
      'onTimeCount': 15,
      'lateCount': 10,
    },
  ];

  GridView _buildGridView(BoxConstraints constraints) {
    return GridView.builder(
      itemCount: sampleOverviewData.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: constraints.maxWidth / 2 / 256,
      ),
      itemBuilder: (BuildContext context, int index) {
        return _overviewCard(index, context);
      },
    );
  }

  Widget _overviewCard(index, BuildContext context) {
    Map<String, dynamic> attendance = sampleOverviewData[index];
    double totalLogs = attendance['onTimeCount'] +
        attendance['lateCount'] +
        attendance['absentCount'] +
        attendance['cuttingCount'];
    return StatefulBuilder(builder: (context, setState) {
      return SizedBox(
        child: Card(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [..._buildOverviewCard(attendance, context, totalLogs)],
            ),
          ),
        ),
      );
    });
  }
}
