// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'package:samids_web_app/src/screen/student/attendance.dart';
import 'package:samids_web_app/src/widgets/circular_viewer.dart';
import 'package:samids_web_app/src/widgets/custom_list_tile.dart';
import 'package:samids_web_app/src/widgets/side_menu.dart';
import 'package:samids_web_app/src/widgets/student_info_card.dart';

import '../../controllers/student_dashboard.controller.dart';
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
  // add on init
  @override
  void initState() {
    widget.sdController.getAttendance();
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
    return MobileView(
      currentIndex: 0,
      appBarTitle: 'Dashboard',
      userName: 'Martin Erickson Lapetaje',
      body: Column(
        children: [
          _mobileOverviewCard(2, 0),
          _mobileRecentLogsCard(0),
        ],
      ),
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
                    StudentInfoCard(),
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
                      children: [
                        Flexible(flex: 1, child: _recentLogsCard(context)),
                        _myClassesCard(context)
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
  DataRow logsSampleDataRow(context) {
    return DataRow(
      cells: <DataCell>[
        DataCell(Text('02:12pm')),
        DataCell(Expanded(
          child: Text(
            textAlign: TextAlign.start,
            '10023 - Programming 1',
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Text('On-Time')),
      ],
    );
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

  Widget dataTableLogs(context) {
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
              'Remark',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        rows: [for (int i = 0; i < 10; i++) logsSampleDataRow(context)],
      ),
    );
  }

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
      child: Column(
        children: List.generate(
          20,
          (index) => CustomListTile(
            title: "Programming $index",
            subtitle: getStatusText("On-Time"),
            leadingIcon: Icons.access_alarm_sharp,
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

  Widget _recentLogsCard([flexValue = 1]) {
    return CardSmall(
      isShadow: false,
      title: "Recent Activity",
      child: Column(
        children: List.generate(
          20,
          (index) => CustomListTile(
            title: "Programming $index",
            subtitle: getStatusText("On-Time"),
            leadingIcon: Icons.access_alarm_sharp,
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

  CardSmall _performanceCard(leadingFlex, [flexValue = 1]) {
    return CardSmall(
      flexValue: flexValue,
      title: "Performance",
      isShadow: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          DataNumber(
              number: "Great!", description: "Rating", flex: leadingFlex),
          DataNumber(number: "11%", description: "Late", flex: 1),
          DataNumber(number: "5%", description: "Absent", flex: 1),
          DataNumber(number: "4%", description: "Cutting", flex: 1),
          DataNumber(number: "35%", description: "On-Time", flex: 1),
        ],
      ),
      // sampleData: sampleDataActyiee,
    );
  }

  Text getStatusText(String status) {
    final String lowercaseStatus = status.toLowerCase();
    Color color;
    switch (lowercaseStatus) {
      case 'absent':
        color = Colors.red;
        break;
      case 'cutting':
        color = Colors.yellow;
        break;
      case 'on-time':
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
    return CardSmall(
      isShadow: true,
      flexValue: flexValue,
      title: "Overview",
      child: Row(
        children: [
          DataNumber(
              number: "55", description: "Total logs", flex: leadingFlex),
          circularData(11, 'Absent', Colors.red),
          circularData(05, 'Cutting', Colors.yellow),
          circularData(04, 'On-Time', Colors.green),
          circularData(35, 'Late', Colors.orange)
        ],
      ),
      // sampleData: sampleDataAct,
    );
  }

  Widget _mobileOverviewCard(leadingFlex, [flexValue = 1]) {
    return MobileSmallCard(
        isShadow: true,
        sideTitle: "Total logs",
        sideTitleTrailer: '55',
        title: "Overview",
        child: Row(
          children: [
            circularData(11.0, 'Absent', Colors.red, 32.0),
            circularData(05.0, 'Cutting', Colors.yellow, 32.0),
            circularData(04.0, 'On-Time', Colors.green, 32.0),
            circularData(35.0, 'Late', Color.fromRGBO(255, 152, 0, 1), 32.0),
          ],
        ));

    // sampleData: sampleDataAct,
  }

  Widget circularData(value, description, color, [radius = 40.0]) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Flexible(
        flex: 1,
        child: Column(
          children: [
            CircularViewer(
              value: value,
              maxValue: 55,
              radius: radius,
              textStyle: TextStyle(fontSize: 20),
              color: Color(0xffEEEEEE),
              sliderColor: color,
              unSelectedColor: Color.fromARGB(255, 255, 255, 255),
            ),
            Text(description),
          ],
        ),
      ),
    );
  }
}
