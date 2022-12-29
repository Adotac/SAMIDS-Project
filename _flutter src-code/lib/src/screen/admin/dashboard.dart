import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';

class AdminDashboard extends StatelessWidget {
  final String pageTitle;
  const AdminDashboard({super.key, required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocalAppBar(pageTitle: pageTitle),
        remarkSection(context),
        Card(
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    barLine(10, 5),
                    barLine(10, 7),
                    barLine(10, 9),
                    barLine(10, 2),
                    barLine(10, 10),
                    barLine(10, 3),
                    barLine(10, 6),
                    barLine(10, 4),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
    ;
  }

  Padding barLine(max, current) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.grey.shade500,
        height: 200 / max * current,
        width: 65,
      ),
    );
  }

  Row remarkSection(BuildContext context) {
    return Row(
      children: [
        remarkCard(context),
        remarkCard(context),
      ],
    );
  }

  Widget remarkCard(BuildContext context) {
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

class TitleMediumText extends StatelessWidget {
  final String title;
  const TitleMediumText({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
