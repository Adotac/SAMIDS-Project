import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  final String pageTitle;
  const AdminDashboard({super.key, required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          // color: Colors.red,
          height: 60,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              pageTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ],
    );
    ;
  }
}
