import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';

import '../../constant/constant_values.dart';
import '../../widgets/bar_line.dart';
import '../../widgets/card_small.dart';
import '../../widgets/title_medium_text.dart';

class AdminDashboard extends StatelessWidget {
  final String pageTitle;
  AdminDashboard({super.key, required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocalAppBar(pageTitle: pageTitle),
        dashboardBody(),
      ],
    );
  }

  // ignore: prefer_const_constructors
  Widget sampleDataAct = Padding(
    padding: const EdgeInsets.all(3.0),
    child: const ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 25,
      ),
      title: Text("Martin Erickson Lapetaje • Prog 1 - 2019"),
      subtitle: Text("12:11 On-Time"),
    ),
  );

  // ignore: prefer_const_constructors
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
  Expanded dashboardBody() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            remarkSection(),
            attendanceBarSection(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                CardSmall(
                  title: "Activities",
                  sampleData: sampleDataAct,
                ),
                CardSmall(
                  title: "Classes",
                  sampleData: sampleDataClasses,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Card attendanceBarSection() {
    return Card(
      child: Container(
        // alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(15),
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            const TitleMediumText(
              title: "Attendance by Class",
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [for (var barLine in barLineSampleData) barLine],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row remarkSection() {
    return Row(
      children: [
        remarkCard(),
        remarkCard(),
      ],
    );
  }

  Widget remarkCard() {
    return Flexible(
      flex: 1,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: const TitleMediumText(
                    title: "Students",
                  )),
              SizedBox(
                // width: MediaQuery.of(context).size.width * .10,
                // width: double.maxFinite,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    dataNumber("55", "Total logs", 5),
                    dataNumber("11", "Late", 1),
                    dataNumber("05", "Absent", 1),
                    dataNumber("04", "Cutting", 1),
                    dataNumber("35", "On-Time", 1),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Flexible dataNumber(number, description, flex) {
    return Flexible(
      flex: flex,
      child: Container(
        // color: Colors.red,
        // width: 80,
        alignment: Alignment.centerLeft,
        // padding: const EdgeInsets.only(right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(description),
          ],
        ),
      ),
    );
  }
}
