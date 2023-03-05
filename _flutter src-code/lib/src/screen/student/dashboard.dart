// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/card_small.dart';
import '../../widgets/data_number.dart';

class StudentDashboard extends StatelessWidget {
  StudentDashboard({super.key});

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

  bool _isSizeNotAllowed(BoxConstraints constraints) {
    return (constraints.maxWidth <= 450);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
      if (_isSizeNotAllowed(constraints)) {
        return Column(
          children: [
            LocalAppBar(pageTitle: "Dashboard"),
            Expanded(
                child: SingleChildScrollView(
              child: Column(children: [
                _mStudentInfo(),
                _overviewCard(2, 0),
                _performanceCard(2, 0),
                recentLogsCard(context, 0),
              ]),
            )),
          ],
        );
      }

      return _webView(context);
    });
  }

  Column _webView(BuildContext context) {
    return Column(
      children: [
        LocalAppBar(pageTitle: "Dashboard"),
        Expanded(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _studentInfo(),
                Row(
                  children: [
                    _overviewCard(5),
                    _performanceCard(3),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    recentLogsCard(context),
                    myClassesCard(),
                  ],
                )

                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Flexible(
                //       flex: 1,
                //       child: Column(
                //         children: [
                //           studentInfo(),
                //           overviewCard(),
                //           recentLogsCard(),
                //         ],
                //       ),
                //     ),
                //     Flexible(
                //       flex: 1,
                //       child: Column(
                //         children: [
                //           performanceCard(),
                //           myClassesCard(),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ))
      ],
    );
  }

  DataRow sampleDataRow(context) {
    return DataRow(
      cells: <DataCell>[
        DataCell(Text('02:12pm')),
        DataCell(SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
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

  Widget dataTable(context) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        dividerThickness: 0,
        columnSpacing: 10,
        // ignore: prefer_const_literals_to_create_immutables
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
        rows: [for (int i = 0; i < 10; i++) sampleDataRow(context)],
      ),
    );
  }

  CardSmall myClassesCard() {
    return CardSmall(
      flexValue: 1,
      title: "My Classes",
      child: Column(
        children: [for (int i = 0; i < 5; i++) sampleDataClasses],
      ),
    );
  }

  Widget recentLogsCard(context, [flexValue = 1]) {
    return CardSmall(
      flexValue: flexValue, title: "Recent Logs", child: dataTable(context),
      // Column(
      //   children: [for (int i = 0; i < 10; i++) sampleDataAct],
      // ),
    );
  }

  CardSmall _performanceCard(leadingFlex, [flexValue = 1]) {
    return CardSmall(
      flexValue: flexValue,
      title: "Performance",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          DataNumber(
              number: "Great!", description: "Rating", flex: leadingFlex),
          DataNumber(number: "11%", description: "Late", flex: 1),
          DataNumber(number: "05%", description: "Absent", flex: 1),
          DataNumber(number: "04%", description: "Cutting", flex: 1),
          DataNumber(number: "35%", description: "On-Time", flex: 1),
        ],
      ),
      // sampleData: sampleDataActyiee,
    );
  }

  Widget _mStudentInfo() {
    return CardSmall(
      title: "",
      flexValue: 0,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Text(
              "Martin Erickson Lapetaje",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              "Bachelor of Science in Computer",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "lapetajemartin@gmail.com",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  CardSmall _studentInfo() {
    return CardSmall(
      title: "",
      flexValue: 0,
      child: Row(children: [
        CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          radius: 54,
        ),
        SizedBox(
          width: 15,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Text(
              "Martin Erickson Lapetaje",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Bachelor of Science in Computer Science",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "lapetajemartin@gmail.com",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ]),
    );
  }

  CardSmall _overviewCard(leadingFlex, [flexValue = 1]) {
    return CardSmall(
      flexValue: flexValue,
      title: "Overview",
      child: Row(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          DataNumber(
              number: "55", description: "Total logs", flex: leadingFlex),
          DataNumber(number: "11", description: "Late", flex: 1),
          DataNumber(number: "05", description: "Absent", flex: 1),
          DataNumber(number: "04", description: "Cutting", flex: 1),
          DataNumber(number: "35", description: "On-Time", flex: 1),
        ],
      ),
      // sampleData: sampleDataAct,
    );
  }
}
