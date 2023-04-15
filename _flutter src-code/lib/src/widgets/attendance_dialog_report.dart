import 'package:flutter/material.dart';

class ReportAttendanceDialog extends StatefulWidget {
  const ReportAttendanceDialog({super.key});

  @override
  _ReportAttendanceDialogState createState() => _ReportAttendanceDialogState();
}

class _ReportAttendanceDialogState extends State<ReportAttendanceDialog> {
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
              children: [
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
    return IconButton(
      onPressed: () {
        _showReportAttendanceDialog(context);
      },
      icon: Icon(
        Icons.report_gmailerrorred_outlined,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
