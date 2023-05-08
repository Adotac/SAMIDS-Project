import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/attendance_dialog_report.dart';

class AttendanceTileFac extends StatelessWidget {
  final String studentNo;
  final String subject;
  final String name;
  // final String referenceNo;
  final String date;
  final String day;
  final String room;
  final String timeIn;
  final String timeOut;
  final Widget remarks;

  const AttendanceTileFac({
    Key? key,
    required this.subject,
    required this.room,
    required this.date,
    required this.timeIn,
    required this.timeOut,
    required this.remarks,
    required this.name,
    // required this.referenceNo,
    required this.day,
    required this.studentNo,
  }) : super(key: key);

  Future<void> _showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => true,
          child: AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Sending...'),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showReportAttendanceDialog(BuildContext context) async {
    TextEditingController _textFieldController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report Attendance Issue'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please provide a brief description of the issue:',
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _textFieldController,
                  decoration: InputDecoration(
                    hintText: 'Enter issue description',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                // Process the submitted issue
                Navigator.of(context).pop();
                await _showLoadingDialog(context);
                await Future.delayed(Duration(seconds: 2));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            // Text('Reference No: $referenceNo'),
            Text('Name: $name'),
            Text('Room: $room'),
            Text('Date: $date'),
            Text('Day: $day'),
            Text('Time In: $timeIn'),
            Text('Time Out: $timeOut'),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            remarks,
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
