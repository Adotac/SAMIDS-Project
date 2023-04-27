// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';

import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:samids_web_app/src/widgets/mobile_view.dart';

import '../../model/attendance_model.dart';

import '../../widgets/attendance_tile.dart';
import '../../widgets/card_small.dart';
import '../../widgets/pagination/student_attendance_data_source.dart';
import '../../widgets/side_menu.dart';
import '../../widgets/web_view.dart';

class StudentAttendance extends StatefulWidget {
  final StudentController sdController;

  const StudentAttendance({
    Key? key,
    required this.sdController,
  }) : super(key: key);
  static const routeName = '/student-attendance';

  @override
  State<StudentAttendance> createState() => _StudentAttendanceState();
}

class _StudentAttendanceState extends State<StudentAttendance>
    with SingleTickerProviderStateMixin {
  final _textEditingController = TextEditingController();
  StudentController get _sdController => widget.sdController;

  bool isMobile(BoxConstraints constraints) {
    return (constraints.maxWidth <= 450);
  }

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
          return _mobileView(context);
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
          animation: _sdController,
          builder: (context, child) {
            return _webAttendanceBody(context);
          }),
    );
  }

  Widget _mobileView(BuildContext context) {
    return MobileView(
      appBarOnly: true,
      appBarTitle: 'Attendance',
      currentIndex: 1,
      body: _mobileAttendanceBody(context),
    );
  }

  Widget _webAttendanceBody(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
          child: Expanded(child: Card(child: _dataTableAttendance(context)))),
    );
  }

  Widget _dataTableAttendance(context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: const EdgeInsets.all(8.0),
      child: PaginatedDataTable(
            columns:  [
            _dataColumn(
             'Reference No',
            ),
            _dataColumn(
              ''
            ),
            _dataColumn(
              label: Text('Room'),
            ),
            _dataColumn(
              label: Text('Time in'),
            ),
            _dataColumn(
              label: Text('Time out'),
            ),
            _dataColumn(
              label: Text('Remarks'),
            ),
            _dataColumn(
              label: Text('Actions'),
            ),
          ],
         showFirstLastButtons: true,
      rowsPerPage: 20,
      onPageChanged: (int value) {
        print('Page changed to $value');
      },
          source: _createAttendanceDataSource()
        ),
      
    );
  }

  AttendanceDataSourceSt _createAttendanceDataSource() {
    return AttendanceDataSourceSt(
      _sdController.filteredAttendanceList,
      _sdController, context
    );
  }
DataColumn _dataColumn(String title) {
    bool isSortedColumn = _sdController.sortColumn == title;

    return DataColumn(
      label: SizedBox(
        width: 100,
        child: InkWell(
          onTap: () {
            _sdController.sortAttendance(title);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (isSortedColumn)
                Icon(
                  _sdController.sortAscending
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
      numeric: false,
    );
  }
  

  List<Widget> _mobileAttendanceBody(BuildContext context) {
    return [
      _searchBar(context),
      SizedBox(height: 8),
      Expanded(
        child: ListView.builder(
          itemCount: _sdController.allAttendanceList.length,
          itemBuilder: (BuildContext context, int i) {
            Attendance attendance = _sdController.allAttendanceList[i];
            return AttendanceTile(
              subject: attendance.subjectSchedule?.subject?.subjectName ??
                  'No Subject',
              room: attendance.subjectSchedule?.room ?? 'No Room',
              date: _sdController.formatDate(_getActualTime(attendance)),
              timeIn: attendance.actualTimeIn != null
                  ? _sdController.formatTime(attendance.actualTimeIn!)
                  : 'No Time In',
              timeOut: attendance.actualTimeOut != null
                  ? _sdController.formatTime(attendance.actualTimeOut!)
                  : 'No Time Out',
              remarks: _sdController.getStatusText(attendance.remarks.name),
            );
          },
        ),
      ),
    ];
  }

  DateTime _getActualTime(Attendance attendance) =>
      attendance.actualTimeOut != null
          ? attendance.actualTimeOut!
          : attendance.actualTimeIn != null
              ? attendance.actualTimeIn!
              : DateTime.now();

  Widget _searchBar(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .30,
      child: TextField(
        autofocus: true,
        onSubmitted: (query) {
          // _dataController.filterAttendance(query);
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
