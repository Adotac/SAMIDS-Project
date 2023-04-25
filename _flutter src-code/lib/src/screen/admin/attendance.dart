// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';

import '../../controllers/admin_controller.dart';
import '../../controllers/student_controller.dart';
import '../../model/attendance_model.dart';
import '../../model/subjectSchedule_model.dart';
import '../../widgets/attendance_data_source.dart';
import '../../widgets/card_small.dart';
import '../../widgets/mobile_view.dart';
import '../../widgets/web_view.dart';

class AdminAttendance extends StatefulWidget {
  static const routeName = '/admin-attendance';
  final AdminController adminController;

  const AdminAttendance({super.key, required this.adminController});

  @override
  State<AdminAttendance> createState() => _AdminAttendanceState();
}

class _AdminAttendanceState extends State<AdminAttendance> {
  final _textEditingController = TextEditingController();

  AdminController get _dataController => widget.adminController;

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

  Widget _mobileView(BuildContext context) {
    return MobileView(
      appBarOnly: true,
      appBarTitle: "Admin Attendance",
      currentIndex: 1, // Set the appropriate index for the current screen
      body: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _searchBar(context),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          scrollDirection: Axis.vertical,
          child: _dataTableAttendance(context),
        ),
      ],
    );
  }

  Widget _webView(BuildContext context) {
    return WebView(
      appBarTitle: "Admin Attendance",
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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      scrollDirection: Axis.vertical,
      child: _dataTableAttendance(context),
    );
  }

  Widget _dataTableAttendance(context) {
    return PaginatedDataTable(
      columns: [
        _dataColumn("Student ID"),
        _dataColumn("Name"),
        _dataColumn("Reference ID"),
        _dataColumn("Room"),
        _dataColumn("Subject"),
        _dataColumn("Date"),
        _dataColumn("Day"),
        _dataColumn("Time In"),
        _dataColumn("Time Out"),
        _dataColumn("Remarks"),
      ],
      showFirstLastButtons: true,
      rowsPerPage: 20,
      onPageChanged: (int value) {
        print('Page changed to $value');
      },
      source: _createAttendanceDataSource(),
    );
  }

  // AttendanceDataSource _createAttendanceDataSource() {
  //   return AttendanceDataSource(
  //     _dataController.allAttendanceList,
  //     _dataController,
  //   );
  // }

  AttendanceDataSource _createAttendanceDataSource() {
    return AttendanceDataSource(
      _dataController.filteredAttendanceList,
      _dataController,
    );
  }

  DataColumn _dataColumn(String title) {
    bool isSortedColumn = _dataController.sortColumn == title;

    return DataColumn(
      label: SizedBox(
        width: 100,
        child: InkWell(
          onTap: () {
            _dataController.sortAttendance(title);
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
                  _dataController.sortAscending
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

  Widget _searchBar(context) {
    return SizedBox(
      // padding: const EdgeInsets.symmetric(horizontal: 12),
      // height: 42,
      width: MediaQuery.of(context).size.width * .30,
      // decoration: BoxDecoration(
      //     color: Colors.white,
      //     shape: BoxShape.rectangle,
      //     borderRadius: BorderRadius.circular(5),
      //     border: Border.all(color: Colors.grey, width: 1)),
      child: TextField(
        autofocus: true,
        onSubmitted: (query) {
          // Call filterAttendance with the search query entered by the user
          _dataController.filterAttendance(query);
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
