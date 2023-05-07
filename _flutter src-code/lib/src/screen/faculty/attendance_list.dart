import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';

import '../../model/attendance_model.dart';
import '../../model/student_model.dart';

class FacultySubjectAttendanceList extends StatefulWidget {
  final FacultyController dataController;
  final String title;
  final int schedId;
  final String subjectId;
  const FacultySubjectAttendanceList({
    Key? key,
    required this.dataController,
    required this.title,
    required this.schedId,
    required this.subjectId,
  }) : super(key: key);

  @override
  _FacultySubjectAttendanceListState createState() =>
      _FacultySubjectAttendanceListState();
}

class _FacultySubjectAttendanceListState
    extends State<FacultySubjectAttendanceList> {
  FacultyController get _dataController => widget.dataController;
  int get schedId => widget.schedId;
  String get title => widget.title;
  String get subjectId => widget.subjectId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$subjectId - $title'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildAttendanceList(context),
        ));
  }

  SingleChildScrollView _buildAttendanceList(BuildContext context) {
    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _dataController.attendanceBySchedId[schedId]!.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attendance list',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 4.0),
                  TextButton(
                      onPressed: () async {
                        await _dataController.downloadAttendanceBySchedId(
                            context, schedId, title, int.parse(subjectId));
                      },
                      child: const Text("Download List")),
                ],
              ),
            );
          }
          Attendance attendance =
              _dataController.attendanceBySchedId[schedId]![index - 1];
          return _attendanceList(attendance);
        },
      ),
    );
  }

  Widget _attendanceList(Attendance attendance) {
    if (_dataController.isGetStudentListByLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ref No. ${attendance.attendanceId}',
                  ),
                  Text(
                    'First Name ${attendance.student?.firstName ?? 'No First Name'}',
                  ),
                  Text(
                    'Last Name: ${attendance.student?.lastName ?? 'No Last Name'}',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time in: ${attendance.actualTimeIn != null ? _dataController.formatTime(attendance.actualTimeIn!) : 'No Time In'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                Text(
                  'Time in: ${attendance.actualTimeOut != null ? _dataController.formatTime(attendance.actualTimeOut!) : 'No Time Out'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: _dataController.getStatusText(attendance.remarks.name),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _tableDataCell(String text) {
    return DataCell(
      Text(
        text,
        style: TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }
}
