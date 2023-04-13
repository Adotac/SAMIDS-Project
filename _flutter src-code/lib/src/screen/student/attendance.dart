// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/student.controller.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:samids_web_app/src/widgets/mobile_view.dart';

import '../../widgets/card_small.dart';
import '../../widgets/side_menu.dart';

class StudentAttendance extends StatelessWidget {
  final _textEditingController = TextEditingController();
  StudentAttendance({super.key, required this.studentController});
  static const routeName = '/student-attendance';

  final StudentController studentController;
  bool isMobile(BoxConstraints constraints) {
    return (constraints.maxWidth <= 450);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 768) {
          return _mobileView(context);
        }
        return _webView(context);
      },
    );
  }

  Widget _webView(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SideMenu(selectedWidgetMarker: 1),
          Expanded(child: _attendanceBody(context)),
        ],
      ),
    );
  }

  Widget _mobileView(BuildContext context) {
    return MobileView(
      appBarTitle: 'Attendance',
      currentIndex: 1,
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
          child: _mobileAttendanceBody(context),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Attendance'),
    );
  }

  Widget _mobileAttendanceBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 18),
        _searchBar(context),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                // _dataColumn("Attendance ID"),
                _dataColumn("Subject"),
                _dataColumn("Room"),
                _dataColumn("Date"),
                _dataColumn("Time In"),
                _dataColumn("Time Out"),
                _dataColumn("Remarks"),
              ],
              rows: [for (int i = 0; i < 20; i++) _sampleDataRow(context)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _attendanceBody(context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Card(
        child: Column(children: [
          SizedBox(height: 18),
          _searchBar(context),
          SizedBox(height: 8),
          Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: DataTable(
                columns: [
                  _dataColumn("Subject"),
                  _dataColumn("Room"),
                  _dataColumn("Date"),
                  _dataColumn("Time In"),
                  _dataColumn("Time Out"),
                  _dataColumn("Remarks"),
                ],
                rows: [for (int i = 0; i < 20; i++) _sampleDataRow(context)],
              ))
        ]),
      ),
    );
  }

  DataRow _sampleDataRow(context) {
    return DataRow(
      // ignore: prefer_const_literals_to_create_immutables
      cells: <DataCell>[
        DataCell(Text('10023 - Programming 1')),
        // DataCell(Text('AD1234KA12')),
        DataCell(Text('BCL3')),
        DataCell(Text('March 05')),
        DataCell(Text('02:12pm')),
        DataCell(Text('03:16pm')),
        DataCell(Text('On-Time')),
      ],
    );
  }

  DataColumn _dataColumn(title) {
    return DataColumn(
      label: Text(
        title,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  Container _searchBar(context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      height: 42,
      width: MediaQuery.of(context).size.width * .80,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey, width: 1)),
      child: TextField(
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
