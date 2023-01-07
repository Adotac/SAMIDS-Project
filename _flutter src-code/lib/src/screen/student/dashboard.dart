// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/card_small.dart';
import '../../widgets/data_number.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocalAppBar(pageTitle: "Dashboard"),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  CardSmall(
                    title: "Overview",
                    child: Row(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        DataNumber(
                            number: "55", description: "Total logs", flex: 5),
                        DataNumber(number: "11", description: "Late", flex: 1),
                        DataNumber(
                            number: "05", description: "Absent", flex: 1),
                        DataNumber(
                            number: "04", description: "Cutting", flex: 1),
                        DataNumber(
                            number: "35", description: "On-Time", flex: 1),
                      ],
                    ),
                    // sampleData: sampleDataAct,
                  ),
                  CardSmall(
                    title: "Performance",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        DataNumber(
                            number: "Great!", description: "Rating", flex: 3),
                        DataNumber(number: "11%", description: "Late", flex: 1),
                        DataNumber(
                            number: "05%", description: "Absent", flex: 1),
                        DataNumber(
                            number: "04%", description: "Cutting", flex: 1),
                        DataNumber(
                            number: "35%", description: "On-Time", flex: 1),
                      ],
                    ),
                    // sampleData: sampleDataActyiee,
                  ),
                ],
              ),
            ],
          ),
        ))
      ],
    );
  }
}
