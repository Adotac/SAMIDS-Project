// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samids_web_app/src/constant/constant_values.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';

import '../../controllers/admin_controller.dart';
import '../../controllers/student_controller.dart';
import '../../model/attendance_model.dart';
import '../../model/student_model.dart';
import '../../model/subjectSchedule_model.dart';
import '../../services/DTO/crud_return.dart';
import '../../widgets/pagination/admin_attendance_data_source.dart';
import '../../widgets/card_small.dart';
import '../../widgets/pagination/faculties_data_source.dart';
import '../../widgets/students_data_source.dart';
import '../../widgets/web_view.dart';
import '../page_size_constriant.dart';

class ManageStudent extends StatefulWidget {
  static const routeName = '/admin-manage-student';
  final AdminController adminController;

  const ManageStudent({super.key, required this.adminController});

  @override
  State<ManageStudent> createState() => _ManageStudentState();
}

class _ManageStudentState extends State<ManageStudent> {
  final _textEditingController = TextEditingController();

  AdminController get _controller => widget.adminController;

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
        // if (constraints.maxWidth < 768) {
        //   return SizedBox();
        //   // _mobileView(context);
        // }

        if (constraints.maxWidth < 1578 || constraints.maxHeight < 854) {
          return const ScreenSizeWarning();
        }
        return _webView(context);
      },
    );
  }

  Widget _webView(BuildContext context) {
    return WebView(
      appBarTitle: "Manage Student",
      selectedWidgetMarker: 2,
      body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return _webMngUser(context);
          }),
    );
  }

  Widget _webMngUser(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCard(
            context,
            'Students',
            _searchBarStudent(context),
            _buildStudentList(),
          ),
          const SizedBox(width: 3.0),
          _buildCard(
            context,
            'Information',
            SizedBox(),
            _buildInformationList(),
          ),
        ],
      ),
    );
  }

  Flexible _buildCard(BuildContext context, title, searchBar, table,
      [int flex = 1]) {
    return Flexible(
      flex: flex,
      child: SingleChildScrollView(
        child: Card(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12.0),
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          decorationThickness: 5.0,
                          fontSize: 24,
                          fontWeight: FontWeight.w900),
                    ),
                    Spacer(),
                    Visibility(
                      visible: title != 'Students',
                      child: Row(
                        children: [
                          Visibility(
                            visible:
                                _controller.selectedStudent?.firstName != null,
                            child: Text(
                              'Selected Student: ',
                              style: TextStyle(
                                  decorationThickness: 5.0,
                                  fontSize: 24,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          Text(
                            '${_controller.selectedStudent?.firstName ?? ''} ${_controller.selectedStudent?.lastName ?? ''}',
                            style: TextStyle(
                                decorationThickness: 5.0,
                                fontSize: 24,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.0),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.center,
                    child: searchBar),
                table
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Color(0xFFF2F2F2),
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.all(18.0),
        child: _dataTableStudents(context));
  }

  Widget _dataTableStudents(BuildContext context) {
    return PaginatedDataTable(
      columns: [
        _dataColumn('Student No', 70),
        // _dataColumn('RFID'),
        _dataColumn('Last Name'),
        _dataColumn('First Name'),
        _dataColumn('Course'),
        _dataColumn('Year', 40),
      ],
      showFirstLastButtons: true,
      rowsPerPage: 20,
      onPageChanged: (int value) {
        print('Page changed to $value');
      },
      source: _createStudentDataSource(),
    );
  }

  StudentDataSource _createStudentDataSource() {
    return StudentDataSource(
        _controller.filteredStudents, _controller, context);
  }

  // AttendanceDataSource _createAttendanceDataSource() {
  //   return AttendanceDataSource(
  //     _controller.allAttendanceList,
  //     _controller,
  //   );
  // }

  DataColumn _dataColumn(String title, [double width = 90]) {
    bool isSortedColumn = _controller.sortColumn == title;

    return DataColumn(
      label: SizedBox(
        width: width,
        child: InkWell(
          onTap: () {
            _controller.sortStudents(title);
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
                  _controller.sortAscending
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

  Widget _searchBarStudent(context) {
    return SizedBox(
        child: TextField(
      onSubmitted: _onSearchSubmittedStudents,
      controller: _textEditingController,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.search_outlined),
        suffixIconColor: Color(0xFFF2F2F2),
        border: InputBorder.none,
        hintText: 'Search Student',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFF2F2F2),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ));
  }

  void _onSearchSubmittedStudents(String query) {
    _controller.searchStudents(query);
  }

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordControllerConfirm =
      TextEditingController();

  Widget _buildInformationList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.52,
            ),
            // height: MediaQuery.of(context).size.height * 0.52,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Color(0xFFF2F2F2),
                width: 2.0,
              ),
            ),
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                _controller.isGettingClasses
                    ? Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context)
                                .primaryColor, // Customize the color
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: _dataTableClasses(context)),
              ],
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Color(0xFFF2F2F2),
                width: 2.0,
              ),
            ),
            padding: const EdgeInsets.all(8.0),
            child: _resetPasswordForm(),
          ),
        ],
      ),
    );
  }

  Widget _resetPasswordForm() {
    usernameController.text =
        _controller.selectedStudent?.studentNo.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Reset Student password",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12.0),
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'New Password',
            ),
            obscureText: true,
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: passwordControllerConfirm,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
            ),
            obscureText: true,
          ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  _onForgetPasswordClick(context);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DataColumn customDataColumn({required Widget label, int flex = 2}) {
    return DataColumn(
      label: Expanded(
        flex: flex,
        child: label,
      ),
    );
  }

  Widget _dataTableClasses(context) {
    return DataTable(
      columns: [
        customDataColumn(label: Text('Subject'), flex: 3),
        customDataColumn(label: Text('Room'), flex: 1),
        customDataColumn(label: Text('Time'), flex: 1),
        customDataColumn(label: Text('Day'), flex: 1),
      ],
      rows: _controller.studentClasses
          .map((attendance) => _buildDataRowClasses(
                context,
                attendance,
              ))
          .toList(),
    );
  }

  DataRow _buildDataRowClasses(BuildContext context, SubjectSchedule schedule) {
    return DataRow(
      cells: [
        DataCell(
          GestureDetector(
            onTap: () {
              _controller.getStudentAttendance(
                schedule.schedId,
              );
              _showAttendanceDialog(context, schedule);
            },
            child: Text(
              "${schedule.schedId} - ${schedule.subject?.subjectName ?? 'No subject name'}",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Text(
            schedule.room.toString(),
            style: TextStyle(fontSize: 14),
          ),
        ),
        DataCell(
          Text(
            getTimeStartEnd(schedule),
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            schedule.day,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String getTimeStartEnd(SubjectSchedule? subjectSchedule) {
    final timeStart =
        _controller.formatTime(subjectSchedule?.timeStart ?? DateTime.now());
    final timeEnd =
        _controller.formatTime(subjectSchedule?.timeEnd ?? DateTime.now());
    return '$timeStart - $timeEnd';
  }

  void _onForgetPasswordClick(context) async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a username or password.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (int.tryParse(usernameController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Username must be a number.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
  }

  void _showAttendanceDialog(BuildContext context, SubjectSchedule schedule) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${_controller.selectedStudent?.firstName ?? ""} ${_controller.selectedStudent?.lastName ?? ""} - ${schedule.subject?.subjectName ?? 'No subject name'}'),
                  // Row(
                  //   children: [
                  //     TextButton(
                  //         onPressed: () async {
                  //           await _controller.downloadAttendanceBySchedId(
                  //               context, schedId, title, subjectId);
                  //         },
                  //         child: Text("Download Table")),
                  //   ],
                  // ),
                ],
              ),
              content: SizedBox(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(
                        label: Text('Date'),
                      ),
                      DataColumn(
                        label: Text('Time In'),
                      ),
                      DataColumn(
                        label: Text('Time out'),
                      ),
                      DataColumn(
                        label: Text('Remarks'),
                      ),
                    ],
                    rows: _controller.studentAttendance
                        .map((attendance) =>
                            _buildAttendanceList(context, attendance))
                        .toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  DataRow _buildAttendanceList(BuildContext context, Attendance attendance) {
    return DataRow(
      cells: [
        // _tableDataCell(attendance.attendanceId.toString()),
        // _tableDataCell(attendance.student?.firstName ?? 'No First Name'),
        // _tableDataCell(attendance.student?.lastName ?? 'No Last Name'),
        _tableDataCell(_formatDate(attendance.date!)),
        _tableDataCell(attendance.actualTimeIn != null
            ? _controller.formatTime(attendance.actualTimeIn!)
            : 'No Time In'),
        _tableDataCell(attendance.actualTimeOut != null
            ? _controller.formatTime(attendance.actualTimeOut!)
            : 'No Time Out'),
        DataCell(
          _controller.getStatusText(attendance.remarks?.name ?? 'Pending'),
        ),
      ],
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

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }
}
