import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AttendanceTile extends StatelessWidget {
  final String subject;
  final String room;
  final String date;
  final String timeIn;
  final String timeOut;
  final Widget remarks;

  const AttendanceTile({
    Key? key,
    required this.subject,
    required this.room,
    required this.date,
    required this.timeIn,
    required this.timeOut,
    required this.remarks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          subject,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: $room'),
            Text('Date: $date'),
            Text('Time In: $timeIn'),
            Text('Time Out: $timeOut'),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            remarks,
            const Spacer(),
            Expanded(
              child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.report_gmailerrorred_outlined,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
