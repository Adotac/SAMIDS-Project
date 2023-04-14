import 'package:flutter/material.dart';
import 'package:samids_web_app/src/model/test_subject.model.dart';

class ClassesListTile extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;
  final bool enableShadow;

  const ClassesListTile({
    Key? key,
    required this.subject,
    required this.onTap,
    this.enableShadow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          boxShadow: enableShadow
              ? const [
                  BoxShadow(
                    spreadRadius: -2,
                    blurRadius: 10,
                    color: Colors.black26,
                    offset: Offset(5, 8),
                  ),
                ]
              : null,
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subject.code,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.caption?.color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  subject.timeSchedule,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subject.daySchedule,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.caption?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
