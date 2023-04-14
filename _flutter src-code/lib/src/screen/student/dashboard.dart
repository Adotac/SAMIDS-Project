// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'package:samids_web_app/src/screen/student/attendance.dart';
import 'package:samids_web_app/src/widgets/circular_viewer.dart';
import 'package:samids_web_app/src/widgets/custom_list_tile.dart';
import 'package:samids_web_app/src/widgets/side_menu.dart';
import 'package:samids_web_app/src/widgets/student_info_card.dart';

import '../../controllers/student_dashboard.controller.dart';
import '../../model/attendance_model.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/card_small.dart';
import '../../widgets/card_small_mobile.dart';
import '../../widgets/data_number.dart';
import '../../widgets/mobile_view.dart';
import '../../widgets/title_medium_text.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class StudentDashboard extends StatefulWidget {
  static const routeName = '/student-dashboard';
  StudentDashboardController sdController = StudentDashboardController.instance;
  StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  StudentDashboardController get _sdController => widget.sdController;
  // add on init
  @override
  void initState() {
    _sdController.getAttendanceToday();
    _sdController.getAttendanceAll();

    super.initState();
  }

  Widget sampleDataAct = const ListTile(
    leading: Text("02:12pm"),
    title: Text("10023 - Programming 1"),
    trailing: Text("On-Time"),
  );

  Widget sampleDataClasses = const ListTile(
    leading: Text("10:30am - 11:30am "),
    title: Text(" 10023 - Programming 1"),
    // subtitle: Text("10023"),
    trailing: Text(
      "On Going",
      style: TextStyle(
        color: Colors.green,
      ),
    ),
  );

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
              ? Column(
                  children: [
                    _mobileOverviewCard(2, 0),
                    _mobileRecentLogsCard(0),
                  ],
                )
              : Column(
                  children: [
                    Spacer(),
                    Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor, // Customize the color
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _webView() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Dashboard"),
        backgroundColor: const Color(0xFFF5F6F9),
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0.1,
      ),
      body: Row(
        children: [
          SideMenu(selectedWidgetMarker: 0),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    StudentInfoCard(student: _sdController.student),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _overviewCard(5),
                        SizedBox(width: 8),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_recentLogsCard(), _myClassesCard(context)],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _webView() {
  //   return Scaffold(
  //     appBar: AppBar(
  //       automaticallyImplyLeading: false,
  //       title: Text("Dashboard"),
  //       backgroundColor: const Color(0xFFF5F6F9),
  //       iconTheme: const IconThemeData(color: Colors.black),
  //       titleTextStyle: const TextStyle(
  //         color: Colors.black,
  //         fontSize: 20,
  //         fontWeight: FontWeight.bold,
  //       ),
  //       elevation: 0.1,
  //     ),
  //     body: SingleChildScrollView(
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           children: [
  //             StudentInfoCard(),
  //             SizedBox(height: 8),
  //             Row(
  //               children: [
  //                 _overviewCard(5),
  //                 SizedBox(width: 8),
  //               ],
  //             ),
  //             SizedBox(height: 8),
  //             _recentLogsCard(context),
  //             SizedBox(height: 8),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _webView(BuildContext context) {
  // DataRow logsSampleDataRow(context) {
  //   return DataRow(
  //     cells: <DataCell>[
  //       DataCell(Text('02:12pm')),
  //       DataCell(Expanded(
  //         child: Text(
  //           textAlign: TextAlign.start,
  //           '10023 - Programming 1',
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       )),
  //       DataCell(Text('On-Time')),
  //     ],
  //   );
  // }

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

  // Widget dataTableLogs(context) {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: DataTable(
  //       dividerThickness: 0,
  //       columnSpacing: 5,
  //       columns: [
  //         DataColumn(
  //           label: Text(
  //             'Time',
  //             style: TextStyle(fontStyle: FontStyle.italic),
  //           ),
  //         ),
  //         DataColumn(
  //           label: Text(
  //             'Subject',
  //             style: TextStyle(fontStyle: FontStyle.italic),
  //           ),
  //         ),
  //         DataColumn(
  //           label: Text(
  //             'Remark',
  //             style: TextStyle(fontStyle: FontStyle.italic),
  //           ),
  //         ),
  //       ],
  //       rows: [for (int i = 0; i < 10; i++) logsSampleDataRow(context)],
  //     ),
  //   );
  // }

  Widget dataTableClasses(context) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        dividerThickness: 0,
        columnSpacing: 5,
        columns: [
          DataColumn(
            label: Text(
              'Time',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Subject',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        rows: [for (int i = 0; i < 10; i++) classesSampleDataRow(context)],
      ),
    );
  }

  CardSmall _myClassesCard(context) {
    return CardSmall(
      flexValue: 1,
      title: "My Classes",
      isShadow: false,
      child: dataTableClasses(context),
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

          print(
            attendance.subjectSchedule?.subject?.subjectName ??
                'No subject name',
          );
          print(
            attendance.subjectSchedule?.subject,
          );

          return CustomListTile(
            title: attendance.subjectSchedule?.subject?.subjectName ??
                'No subject name',
            subtitle: getStatusText(attendance.remarks.name),
            leadingIcon: Icon(getStatusIcon(attendance.remarks),
                color: Theme.of(context).scaffoldBackgroundColor),
            leadingColors: getStatusColor(attendance.remarks, context),
            trailingText: _sdController.formatTime(_getActualTime(attendance)),
            subTrailingText: attendance.subjectSchedule?.schedId.toString() ??
                'No subject id',
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

  Widget _recentLogsCard() {
    return CardSmall(
      flexValue: 1,
      isShadow: false,
      title: "Recent Activity",
      child: Column(
        children: List.generate(
          20,
          (index) => CustomListTile(
            leadingColors: Colors.white,
            title: "Programming $index",
            subtitle: getStatusText("On-Time"),
            leadingIcon: Icon(
              Icons.access_alarm_sharp,
            ),
            trailingText: "02:12pm",
            subTrailingText: '10023',
          ),
        ),
      ),
    );
    //  Row(

    // ));
    // dataTableLogs(context));
  }

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

  Color getStatusColor(Remarks remarks, BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    switch (remarks) {
      case Remarks.onTime:
        return Colors.green; // Modify with the desired color for onTime
      case Remarks.late:
        return Colors.orange; // Modify with the desired color for late
      case Remarks.cutting:
        return Colors
            .yellow.shade700; // Modify with the desired color for cutting
      case Remarks.absent:
        return Colors.red
            .withOpacity(0.5); // Modify with the desired color for absent
    }
  }

  Text getStatusText(String status) {
    final String lowercaseStatus = status.toLowerCase();
    Color color;
    switch (lowercaseStatus) {
      case 'absent':
        color = Colors.red;
        break;
      case 'cutting':
        color = Colors.yellow.shade700;
        break;
      case 'ontime':
        color = Colors.green;
        break;
      case 'late':
        color = Colors.orange;
        break;
      default:
        color = Colors.black;
        break;
    }
    return Text(
      status,
      style: TextStyle(color: color),
    );
  }

  CardSmall _overviewCard(leadingFlex, [flexValue = 1]) {
    double totalLogs = _sdController.allAttendance.length.toDouble();
    return CardSmall(
      isShadow: true,
      flexValue: flexValue,
      title: "Overview",
      child: Row(
        children: [
          DataNumber(
              number: totalLogs.toString(),
              description: "Total logs",
              flex: leadingFlex),
          Spacer(),
          circularData(_sdController.absentCount, 'Absent', Colors.red),
          circularData(
              _sdController.cuttingCount, 'Cutting', Colors.yellow.shade700),
          circularData(_sdController.onTimeCount, 'On-Time', Colors.green),
          circularData(_sdController.lateCount, 'Late', Colors.orange)
        ],
      ),
      // sampleData: sampleDataAct,
    );
  }

  Widget _mobileOverviewCard(leadingFlex, [flexValue = 1]) {
    return AnimatedBuilder(
      animation: _sdController,
      builder: (context, child) {
        double totalLogs = _sdController.allAttendance.length.toDouble();
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
    print(_sdController.lateCount);
    print(_sdController.onTimeCount);
    print(_sdController.cuttingCount);
    print(_sdController.absentCount);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircularViewer(
            value: value,
            maxValue: _sdController.allAttendance.length.toDouble(),
            radius: radius,
            textStyle: TextStyle(fontSize: 20),
            color: Color(0xffEEEEEE),
            sliderColor: color,
            unSelectedColor: Color.fromARGB(255, 255, 255, 255),
          ),
          Text(description),
        ],
      ),
    );
  }
}
