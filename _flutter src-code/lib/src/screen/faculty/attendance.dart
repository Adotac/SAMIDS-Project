// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';

import '../../controllers/student_controller.dart';
import '../../model/attendance_model.dart';
import '../../model/subjectSchedule_model.dart';
import '../../widgets/card_small.dart';
import '../../widgets/web_view.dart';

class FacultyAttendance extends StatefulWidget {
  static const routeName = '/faculty-attendance';
  final FacultyController dataController;

  const FacultyAttendance({super.key, required this.dataController});

  @override
  State<FacultyAttendance> createState() => _FacultyAttendanceState();
}

class _FacultyAttendanceState extends State<FacultyAttendance> {
  final _textEditingController = TextEditingController();

  FacultyController get _dataController => widget.dataController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 768) {
          return SizedBox();
          // _mobileView(context);
        }
        return _webView(context);
      },
    );
  }

  Widget _webView(BuildContext context) {
    return WebView(
      appBarTitle: "Attendance",
      appBarActionWidget: _searchBar(context),
      selectedWidgetMarker: 1,
      body: AnimatedBuilder(
          animation: _dataController,
          builder: (context, child) {
            return _webAttendanceBody(context);
          }),
    );
  }

  Widget _webAttendanceBody(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Card(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: _dataTableAttendance(context),
        ),
      ),
    );
  }

  Widget _dataTableAttendance(context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width * 0.9,
      child: DataTable(
        columns: [
          _dataColumn("Student ID"),
          _dataColumn("Name"),
          _dataColumn("Reference ID"),
          _dataColumn("Room"),
          _dataColumn("Subject"),
          _dataColumn("Date"),
          _dataColumn("Time In"),
          _dataColumn("Time Out"),
          _dataColumn("Remarks"),
        ],
        rows: _dataController.allAttendanceList
            .map((attendance) => _buildAttendanceRow(context, attendance))
            .toList(),
      ),
    );
  }

  DataCell dataCell(String data) {
    return DataCell(
      Text(
        data,
      ),
    );
  }

  DataRow _buildAttendanceRow(BuildContext context, Attendance attendance) {
    return DataRow(
      cells: [
        dataCell(attendance.student?.studentID.toString() ?? 'No student ID'),
        dataCell(
            '${attendance.student?.firstName} ${attendance.student?.lastName}'),
        dataCell(attendance.attendanceId.toString()),
        dataCell(attendance.subjectSchedule?.room ?? 'No Room'),
        dataCell(attendance.subjectSchedule?.subject?.subjectName ??
            'No subject name'),
        dataCell(attendance.subjectSchedule?.day.name ?? 'No Day'),
        dataCell(attendance.actualTimeIn != null
            ? _dataController.formatTime(attendance.actualTimeIn!)
            : 'No Time In'),
        dataCell(attendance.actualTimeOut != null
            ? _dataController.formatTime(attendance.actualTimeOut!)
            : 'No Time Out'),
        DataCell(
          _dataController.getStatusText(attendance.remarks.name),
        ),
      ],
    );
  }

  DataColumn _dataColumn(String title) {
    return DataColumn(
      label: SizedBox(
        width: 100, // Set a fixed width as per your requirement
        child: Flexible(
          child: Text(
            title,
            style: TextStyle(fontStyle: FontStyle.italic),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Container _searchBar(context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 42,
      width: MediaQuery.of(context).size.width * .30,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey, width: 1)),
      child: TextField(
        autofocus: true,
        onSubmitted: (_textEditingController) {
          if (kDebugMode) {
            print(_textEditingController.toString());
          }
        },
        controller: _textEditingController,
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.search_outlined),
          suffixIconColor: Colors.grey,
          border: InputBorder.none,
          hintText: 'Search',
        ),
      ),
    );
  }
}
