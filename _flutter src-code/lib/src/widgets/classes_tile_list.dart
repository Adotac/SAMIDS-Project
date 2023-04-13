import 'package:flutter/material.dart';
import 'package:samids_web_app/src/model/test_subject.model.dart';

class ClassesListTile extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;

  ClassesListTile({required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Card(
        child: ListTile(
          onTap: onTap,
          title: Text(subject.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subject.code),
              Text(subject.timeSchedule),
              Text(subject.daySchedule),
            ],
          ),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
