import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';

import '../../widgets/bar_line.dart';
import '../../widgets/card_small.dart';
import '../../widgets/title_medium_text.dart';

class AdminDashboard extends StatelessWidget {
  final String pageTitle;
  const AdminDashboard({super.key, required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [LocalAppBar(pageTitle: pageTitle), dashboardBody()],
    );
    ;
  }

  Expanded dashboardBody() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          // color: Colors.red,
          // height: MediaQuery.of(context).size.height * .80,
          child: Column(
            children: [
              remarkSection(),
              attendanceBarSection(),
              Row(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const CardSmall(
                    title: "Activities",
                  ),
                  const CardSmall(
                    title: "Classes",
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Card attendanceBarSection() {
    return Card(
      child: Container(
        alignment: Alignment.centerLeft,
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
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const BarLine(max: 8, current: 5, subject: "Prog - 10023"),
                  const BarLine(max: 9, current: 7, subject: "Prog2 - 2423"),
                  const BarLine(
                      max: 11,
                      current: 9,
                      subject: "DataStruct - 1234 sdadsdasdsad"),
                  const BarLine(max: 8, current: 2, subject: "AppsDev - 3124"),
                  const BarLine(max: 15, current: 10, subject: "QM - 9321"),
                  const BarLine(max: 5, current: 3, subject: "Algo - 1032"),
                  const BarLine(max: 15, current: 6, subject: "Digital -10234"),
                  const BarLine(max: 12, current: 4, subject: "IM - 2321"),
                  const BarLine(max: 8, current: 5, subject: "Prog - 10023"),
                  const BarLine(max: 9, current: 7, subject: "Prog2 - 2423"),
                  const BarLine(
                      max: 11,
                      current: 9,
                      subject: "DataStruct - 1234 sdadsdasdsad"),
                  const BarLine(max: 8, current: 2, subject: "AppsDev - 3124"),
                  const BarLine(max: 15, current: 10, subject: "QM - 9321"),
                  const BarLine(max: 5, current: 3, subject: "Algo - 1032"),
                  const BarLine(max: 15, current: 6, subject: "Digital -10234"),
                  const BarLine(max: 12, current: 4, subject: "IM - 2321"),
                  const BarLine(max: 8, current: 5, subject: "Prog - 10023"),
                  const BarLine(max: 9, current: 7, subject: "Prog2 - 2423"),
                  const BarLine(
                      max: 11,
                      current: 9,
                      subject: "DataStruct - 1234 sdadsdasdsad"),
                  const BarLine(max: 8, current: 2, subject: "AppsDev - 3124"),
                  const BarLine(max: 15, current: 10, subject: "QM - 9321"),
                  const BarLine(max: 5, current: 3, subject: "Algo - 1032"),
                  const BarLine(max: 15, current: 6, subject: "Digital -10234"),
                  const BarLine(max: 12, current: 4, subject: "IM - 2321"),
                ],
              ),
            )
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

