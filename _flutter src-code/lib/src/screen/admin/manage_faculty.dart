// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/constant/constant_values.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';

import '../../controllers/admin_controller.dart';
import '../../controllers/student_controller.dart';
import '../../model/attendance_model.dart';
import '../../model/student_model.dart';
import '../../model/subjectSchedule_model.dart';
import '../../services/auth.services.dart';
import '../../services/faculty.services.dart';
import '../../widgets/pagination/admin_attendance_data_source.dart';
import '../../widgets/card_small.dart';
import '../../widgets/pagination/faculties_data_source.dart';
import '../../widgets/students_data_source.dart';
import '../../widgets/web_view.dart';
import '../page_size_constriant.dart';

class ManageFaculty extends StatefulWidget {
  static const routeName = '/admin-manage-faculty';
  final AdminController adminController;

  const ManageFaculty({super.key, required this.adminController});

  @override
  State<ManageFaculty> createState() => _ManageFacultyState();
}

class _ManageFacultyState extends State<ManageFaculty> {
  final _textEditingController = TextEditingController();
  final _textEditingControllerFaculty = TextEditingController();

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
      appBarTitle: "Manage Faculty",
      selectedWidgetMarker: 3,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            context,
            'Faculty',
            _searchBarFaculty(context),
            _buildFacultyList(),
            2,
          ),
          _buildCard(
            context,
            'Information',
            SizedBox(),
            buildInformationList(),
            3,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          decorationThickness: 5.0,
                          fontSize: 24,
                          fontWeight: FontWeight.w900),
                    ),
                    Visibility(
                      visible: title == 'Faculty',
                      child: const Spacer(),
                    ),
                    Visibility(
                      visible: title == 'Faculty',
                      child: _addFaculty(),
                    ),
                    Visibility(
                      visible: title != 'Faculty',
                      child: Row(
                        children: [
                          Visibility(
                            visible:
                                _controller.selectedFaculty?.firstName != null,
                            child: Text(
                              'Selected Faculty: ',
                              style: TextStyle(
                                  decorationThickness: 5.0,
                                  fontSize: 24,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          Text(
                            '${_controller.selectedFaculty?.firstName ?? ''} ${_controller.selectedFaculty?.lastName ?? ''}',
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

  TextButton _addFaculty() {
    return TextButton(
      onPressed: () async {
        String? firstName;
        String? lastName;
        String? facultyId;

        // Show a dialog to get the first name and last name
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Add Faculty'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Faculty ID'),
                  onChanged: (value) => facultyId = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'First Name'),
                  onChanged: (value) => firstName = value,
                ),
                SizedBox(height: 8.0),
                TextField(
                  decoration: InputDecoration(labelText: 'Last Name'),
                  onChanged: (value) => lastName = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Check if first name and last name are not empty
                  if (firstName == null || lastName == null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text('First name and last name are required.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  // Call onUpdateFaculty to add the faculty
                  await _controller.addNewFaculty(
                    facultyId!,
                    firstName!,
                    lastName!,
                  );

                  Navigator.of(context).pop();
                },
                child: Text('Add'),
              ),
            ],
          ),
        );
      },
      child: Text('Add Faculty'),
    );
  }

  Widget buildInformationList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.52,
            ),
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
                _controller.selectedFaculty?.firstName == null
                    ? SizedBox(
                        height: 10,
                      )
                    : Container(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            TextEditingController subjectIdController =
                                TextEditingController();
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Add Subject'),
                                content: TextField(
                                  controller: subjectIdController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Enter subject ID',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      // Validate the subject ID
                                      String subjectId =
                                          subjectIdController.text;
                                      if (subjectId.isEmpty) {
                                        return;
                                      }
                                      int id = int.tryParse(subjectId) ?? -1;
                                      if (id == -1) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Invalid Subject ID',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                            content: Text(
                                                'Subject ID must be a number'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                        return;
                                      }

                                      // Add the subject to the selected faculty
                                      CRUDReturn response =
                                          await _controller.addFacultySubject(
                                        _controller.selectedFaculty!.facultyNo,
                                        id,
                                      );
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pop();
                                      // ignore: use_build_context_synchronously
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            style: TextStyle(
                                                color: response.success
                                                    ? Colors.green
                                                    : Colors.red),
                                            response.success
                                                ? 'Success'
                                                : 'Error',
                                          ),
                                          content: Text(response.data),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Text('Add'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text("Add Subject"),
                        ),
                      ),
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

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordControllerConfirm =
      TextEditingController();
  Widget _resetPasswordForm() {
    usernameController.text =
        _controller.selectedFaculty?.facultyNo.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Reset faculty password",
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

    if (passwordController.text != passwordControllerConfirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final result = await AuthService.changePassword(
      passwordController.text,
      int.parse(usernameController.text),
      _controller.selectedUserType == 'Student' ? 'studentNo' : 'facultyNo',
    );
    print('result.success');
    print(result.success);
    print(result);
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password changed successfully.'),
        backgroundColor: Colors.green,
      ));

      usernameController.text = '';
      passwordController.text = '';
      passwordControllerConfirm.text = '';
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.data),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildFacultyList() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Color(0xFFF2F2F2),
          width: 2.0,
        ),
      ),
      padding: const EdgeInsets.all(18.0),
      child: _dataTableFaculty(context),
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
      rows: _controller.tempFacultyClasses
          .map((attendance) => _buildDataRowClasses(context, attendance))
          .toList(),
    );
  }

  DataRow _buildDataRowClasses(BuildContext context, SubjectSchedule schedule) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            "${schedule.schedId} - ${schedule.subject?.subjectName ?? 'No subject name'}",
            style: TextStyle(fontSize: 14),
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

  DataColumn customDataColumn({required Widget label, int flex = 2}) {
    return DataColumn(
      label: Expanded(
        flex: flex,
        child: label,
      ),
    );
  }
  // AttendanceDataSource _createAttendanceDataSource() {
  //   return AttendanceDataSource(
  //     _dataController.allAttendanceList,
  //     _dataController,
  //   );
  // }

  DataColumn _dataColumnFaculty(String title) {
    bool isSortedColumn = _controller.sortColumnFaculties == title;

    return DataColumn(
      label: SizedBox(
        width: 150,
        child: InkWell(
          onTap: () {
            _controller.sortFaculties(title);
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

  Widget _dataTableFaculty(BuildContext context) {
    return Container(
      child:
          //  SizedBox(),
          PaginatedDataTable(
        columns: [
          _dataColumnFaculty('Faculty No'),
          _dataColumnFaculty('Last Name'),
          _dataColumnFaculty('First Name'),
        ],
        showFirstLastButtons: true,
        rowsPerPage: 20,
        onPageChanged: (int value) {
          print('Page changed to $value');
        },
        source: _createFacultyDataSource(),
        // checkboxHorizontalMargin: 0,
      ),
    );
  }

  FacultyDataSource _createFacultyDataSource() {
    return FacultyDataSource(
        _controller.filteredFaculties, _controller, context);
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

  Widget _searchBarFaculty(context) {
    return SizedBox(
      child: TextField(
        onSubmitted: _onSearchSubmittedFaculties,
        controller: _textEditingControllerFaculty,
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.search_outlined),
          suffixIconColor: Color(0xFFF2F2F2),
          border: InputBorder.none,
          hintText: 'Search Faculty',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFFF2F2F2),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  void _onSearchSubmittedFaculties(String query) {
    _controller.searchFaculties(query);
  }
}
