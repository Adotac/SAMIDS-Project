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
        Row(
          children: [
            userRemarkStats(context),
            userRemarkStats(context),
          ],
        )
      ],
    );
    ;
  }

  Widget userRemarkStats(BuildContext context) {
    return Card(
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
              child: const Text(
                "Students",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .39,
              // width: double.maxFinite,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: dataNumber("55", "Total logs"),
                  ),
                  dataNumber("35", "On-Time"),
                  dataNumber("11", "Late"),
                  dataNumber("05", "Absent"),
                  dataNumber("04", "Cutting"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container dataNumber(number, description) {
    return Container(
      // color: Colors.red,
      width: 80,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(right: 10),
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
    );
  }
}
