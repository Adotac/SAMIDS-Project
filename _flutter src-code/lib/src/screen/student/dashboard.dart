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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocalAppBar(pageTitle: "Dashboard"),
        Expanded(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                studentInfo(),
                Row(
                  children: [
                    overviewCard(),
                    performanceCard(),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    recentLogsCard(),
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

  CardSmall myClassesCard() {
    return CardSmall(
      flexValue: 1,
      title: "My Classes",
      child: Column(
        children: [for (int i = 0; i < 5; i++) sampleDataClasses],
      ),
    );
  }

  CardSmall recentLogsCard() {
    return CardSmall(
      flexValue: 1,
      title: "Recent Logs",
      child: Column(
        children: [for (int i = 0; i < 10; i++) sampleDataAct],
      ),
    );
  }

  CardSmall performanceCard() {
    return CardSmall(
      flexValue: 1,
      title: "Performance",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DataNumber(number: "Great!", description: "Rating", flex: 3),
          DataNumber(number: "11%", description: "Late", flex: 1),
          DataNumber(number: "05%", description: "Absent", flex: 1),
          DataNumber(number: "04%", description: "Cutting", flex: 1),
          DataNumber(number: "35%", description: "On-Time", flex: 1),
        ],
      ),
      // sampleData: sampleDataActyiee,
    );
  }

  CardSmall studentInfo() {
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

  CardSmall overviewCard() {
    return CardSmall(
      flexValue: 1,
      title: "Overview",
      child: Row(
        children: [
          DataNumber(number: "55", description: "Total logs", flex: 5),
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
