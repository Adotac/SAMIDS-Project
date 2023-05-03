import 'package:flutter/material.dart';
import 'package:samids_web_app/src/model/subjectSchedule_model.dart';
import 'package:intl/intl.dart';
import '../model/Subject_model.dart';

class ClassesListTile extends StatelessWidget {
  final Subject? subject;
  final SubjectSchedule? subjectSchedule;
  final VoidCallback onTap;
  final bool enableShadow;

  const ClassesListTile({
    Key? key,
    required this.subject,
    required this.onTap,
    this.enableShadow = false,
    required this.subjectSchedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 0,
        child: Container(
          // margin: const EdgeInsets.symmetric(vertical: 3.0),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${subjectSchedule?.schedId.toString() ?? "No Subject Code"}  ${subject?.subjectName ?? "No Subject Name"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subjectSchedule?.room ?? 'No Class Room',
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
                    subjectSchedule != null
                        ? getTimeStartEnd(subjectSchedule!)
                        : 'No Time Schedule',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subjectSchedule?.day ?? 'No Class Day  ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getTimeStartEnd(SubjectSchedule subjectSchedule) {
    final timeStart = formatTime(subjectSchedule.timeStart);
    final timeEnd = formatTime(subjectSchedule.timeEnd);
    return '$timeStart - $timeEnd';
  }

  String formatTime(DateTime dateTime) {
    final formattedTime = DateFormat('hh:mm a').format(dateTime);
    return formattedTime;
  }
}
