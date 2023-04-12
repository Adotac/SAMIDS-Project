// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';

import '../../constant/constant_values.dart';
import '../../widgets/bar_line.dart';
import '../../widgets/card_small.dart';
import '../../widgets/data_number.dart';
import '../../widgets/title_medium_text.dart';

// ignore: must_be_immutable
class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});
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
                remarkCard(0, 2),
                attendanceBarSection(),
                CardSmall(
                  isShadow: true,
                  flexValue: 0,
                  title: "Activities",
                  child: Column(
                    children: [for (int i = 0; i < 10; i++) mSampleDataAct],
                  ),
                ),
              ]),
            )),
          ],
        );
      }

      return _webView();
    });
  }

  Column _webView() {
    return Column(
      children: [
        LocalAppBar(pageTitle: "Dashboard"),
        dashboardBody(),
      ],
    );
  }

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

  Widget mSampleDataAct = Padding(
    padding: const EdgeInsets.all(3.0),
    child: const ListTile(
      title: Text("Martin Erickson Lapetaje • Prog 1 - 2019"),
      subtitle: Text("12:11 On-Time"),
    ),
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
                  isShadow: true,
                  title: "Activities",
                  child: sampleDataAct,
                ),
                CardSmall(
                  isShadow: true,
                  title: "Classes",
                  child: sampleDataClasses,
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

  Widget remarkCard([flexValue = 1, flexTitle = 5]) {
    return Flexible(
      flex: flexValue,
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
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    DataNumber(
                        number: "55",
                        description: "Total logs",
                        flex: flexTitle),
                    DataNumber(number: "11", description: "Late", flex: 1),
                    DataNumber(number: "05", description: "Absent", flex: 1),
                    DataNumber(number: "04", description: "Cutting", flex: 1),
                    DataNumber(number: "35", description: "On-Time", flex: 1),
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
