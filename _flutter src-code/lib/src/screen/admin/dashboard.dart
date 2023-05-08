import 'dart:io';
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:samids_web_app/src/screen/admin/manage_subjects.dart';
import 'package:samids_web_app/src/screen/page_size_constriant.dart';

import '../../controllers/admin_controller.dart';
import '../../model/faculty_model.dart';
import '../../services/DTO/crud_return.dart';
import '../../services/attendance.services.dart';
import '../../services/auth.services.dart';
import '../../services/config.services.dart';
import '../../widgets/Csv-upload/students.dart';
import '../../widgets/mobile_view.dart';
import '../../widgets/web_view.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class AdminDashboard extends StatefulWidget {
  static const String routeName = '/admin-dashboard';
  final AdminController adminController;
  const AdminDashboard({super.key, required this.adminController});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  AdminController get adminController => widget.adminController;

  @override
  void initState() {
    adminController.getSubjectSchedules();
    adminController.getSubjects();
    adminController.getConfig();
    adminController.getStudents();
    adminController.getAttendanceAll();
    adminController.getFaculties();

    super.initState();
  }

  bool isMobile(BoxConstraints constraints) {
    return (constraints.maxWidth <= 450);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
      // Navigator.popAndPushNamed(context, ManageSubjects.routeName);
      if (constraints.maxWidth < 360 || constraints.maxHeight < 650) {
        return const ScreenSizeWarning();
      }

      if (isMobile(constraints)) {
        return _mobileView();
      }

      if (constraints.maxWidth < 1578 || constraints.maxHeight < 854) {
        return const ScreenSizeWarning();
      }

      return _webView();
    });
  }

  Widget _webView() {
    return AnimatedBuilder(
      animation: adminController,
      builder: (context, child) {
        return WebView(
          appBarTitle: "Admin Dashboard",
          selectedWidgetMarker: 0,
          body:
              //  adminController.config == null
              //     ? const Center(child: CircularProgressIndicator())
              //     :
              _webDashboardBody(),
        );
      },
    );
  }

  Widget _mobileView() {
    return AnimatedBuilder(
      animation: adminController,
      builder: (context, child) {
        return MobileView(
            routeName: AdminDashboard.routeName,
            isAdmin: true,
            appBarTitle: "Admin Dashboard",
            appBarOnly: true,
            currentIndex: 0,
            body: [
              SingleChildScrollView(
                // padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    _mBuildConfig(context),
                    // const Divider(),
                    // _mBuildUpload(),
                    const Divider(),
                    _mBuildDownloadCSV(),
                  ],
                ),
              ),
            ]);
      },
    );
  }

  Widget _webDashboardBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildConfig(context),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: _buildUpload(),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: _buildDownloadCSV(),
          )
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8.0),
              const Text('CSV Format Information'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                    '1. Faculty:', 'Faculty Number,Last Name,First Name'),
                const SizedBox(height: 12),
                _buildInfoRow('2. Student:',
                    'Student Number,RFID,Last Name,First Name,Course,Year Level'),
                const SizedBox(height: 12),
                _buildInfoRow('3. Subject:',
                    'Subject ID,Subject Name,Subject Description,Start Time,End Time,Day,Room'),
                const SizedBox(height: 12),
                _buildInfoRow(
                    '4. Student Subject:', 'Student Number,Offer Code'),
                const SizedBox(height: 12),
                _buildInfoRow(
                    '5. Faculty Subject:', 'Faculty Number,Offer Code'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialogDownload(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8.0),
              const Text('Download Requirements'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                    '1. Faculty Id and student Id should not be null.', ''),
                const SizedBox(height: 12),
                _buildInfoRow(
                    '2. Subject Id if left empty will default to ALL.', ''),
                const SizedBox(height: 12),
                _buildInfoRow(
                    '3. From and to date if left empty will default to ALL.',
                    ''),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Visibility(
          visible: details.isNotEmpty,
          child: Expanded(
            flex: 3,
            child: Text(details),
          ),
        ),
      ],
    );
  }

  Widget _buildUpload() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.all(0.0),
            child: Container(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Upload',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          _showInfoDialog(context);
                        },
                        icon: Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTextButton('Student', () => _uploadCSV(0)),
                      const SizedBox(width: 12.0),
                      _buildTextButton('Subject', () => _uploadCSV(1)),
                      const SizedBox(width: 12.0),
                      _buildTextButton('Faculty', () => _uploadCSV(2)),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTextButton(
                          'Faculty Subject', () => _uploadCSV(3), 180),
                      const SizedBox(width: 12.0),
                      _buildTextButton(
                          'Student Subject', () => _uploadCSV(4), 180),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          _uploadList(),
        ],
      ),
    );
  }

  Card _uploadList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    adminController.clearList();
                  },
                  child: const Text("Clear all"),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Color(0xFFF2F2F2),
                    width: 2.0,
                  )),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.27,
                    minHeight: 500,
                  ),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('File Name')),
                      DataColumn(label: Text('Table Selected')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: adminController.selectedFiles.isEmpty
                        ? List.generate(
                            10,
                            (index) => const DataRow(
                              cells: [
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                              ],
                            ),
                          )
                        : List.generate(
                            adminController.selectedFiles.length,
                            (index) => DataRow(
                              cells: [
                                DataCell(
                                    Text(adminController.selectedFiles[index])),
                                DataCell(Text(
                                    adminController.selectedFileTable[index])),
                                DataCell(
                                  Text(
                                    adminController.uploadStatus[index],
                                    style: TextStyle(
                                      color: adminController
                                                  .uploadStatus[index] ==
                                              'Failed'
                                          ? Theme.of(context).colorScheme.error
                                          : adminController
                                                      .uploadStatus[index] ==
                                                  'Uploading'
                                              ? Colors.black
                                              : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadCSV() {
    return Card(
      margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                const Text(
                  'Download Attendance',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    _showInfoDialogDownload(context);
                  },
                  icon: Icon(
                    Icons.info_outline_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          _downloadForm(),
          const SizedBox(height: 6.0),
        ],
      ),
    );
  }

  Widget _mBuildDownloadCSV() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   'Download Attendance CSV',
          //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 16.0),
          // _mDownloadForm(),
          // const SizedBox(height: 18.0),
          // const Text(
          //   'Reset Password',
          //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 16.0),
          _mResetPasswordForm(),
        ],
      ),
    );
  }

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Widget _resetPasswordForm() {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Reset faculty/student password",
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
                  DropdownButton<String>(
                    value: adminController.selectedUserType,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        adminController.setSelectedUserType(newValue);
                      }
                    },
                    items: <String>['Student', 'Faculty'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onForgetPasswordClick(context) {
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
    AuthService.changePassword(
      passwordController.text,
      int.parse(usernameController.text),
      adminController.selectedUserType == 'Student' ? 'studentNo' : 'facultyNo',
    ).then((result) {
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password changed successfully.'),
          backgroundColor: Colors.green,
        ));

        usernameController.text = '';
        passwordController.text = '';
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.data),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });
  }

  Widget _mResetPasswordForm() {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reset faculty/student password",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            TextButton(
              onPressed: () {
                _onForgetPasswordClick(context);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Column _downloadForm() {
    final DateFormat displayDateFormat = DateFormat('MMMM d, y');
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Color(0xFFF2F2F2),
                width: 2.0,
              )),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Faculty",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Faculty ID",
                  ),
                  controller: adminController.facultyIdController,

                  // Do something with the new value
                ),
                const SizedBox(height: 8.0),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Subject ID",
                  ),
                  controller: adminController.subjectIdFacController,
                ),
                // const SizedBox(height: 8.0),
                // add date picker here
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "From",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          adminController.selectedDateFacFrom == null
                              ? "Select Date"
                              : displayDateFormat
                                  .format(adminController.selectedDateFacFrom!),
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (selectedDate != null) {
                              print(selectedDate);
                              adminController
                                  .setSelectedDateFacFrom(selectedDate);

                              // Do something with the selected date
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "To",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          adminController.selectedDateFacTo == null
                              ? "Select Date"
                              : displayDateFormat
                                  .format(adminController.selectedDateFacTo!),
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (selectedDate != null) {
                              print(selectedDate);
                              adminController
                                  .setSelectedDateFacTo(selectedDate);

                              // Do something with the selected date
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        if (!isNumber(
                            adminController.facultyIdController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Faculty ID must be a number"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (adminController
                                .subjectIdStudController.text.isNotEmpty &&
                            !isNumber(
                                adminController.subjectIdFacController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Subject ID must be a number"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // await adminController.getDataToDownload(
                        //     1,
                        //     int.parse(adminController.facultyIdController.text),
                        //     adminController.selectedDateFac == null
                        //         ? null
                        //         : dateFormat
                        //             .format(adminController.selectedDateFac!),
                        //     adminController
                        //             .subjectIdStudController.text.isNotEmpty
                        //         ? int.parse(
                        //             adminController.subjectIdFacController.text)
                        //         : null,
                        //     context);
                        // Do something with the faculty data
                      },
                      child: Container(
                          alignment: Alignment.center,
                          width: 420,
                          height: 50,
                          child: const Text('Download')),
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
        _fromAttendance(dateFormat, displayDateFormat)
      ],
    );
  }

  Widget _fromAttendance(dateFormat, displayDateFormat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Color(0xFFF2F2F2),
            width: 2.0,
          )),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Student",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                labelText: "Student ID",
              ),
              controller: adminController.studentIdController,
            ),
            const SizedBox(height: 8.0),
            TextField(
              decoration: const InputDecoration(
                labelText: "Subject ID",
              ),
              controller: adminController.subjectIdStudController,
            ),
            const SizedBox(height: 8.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "From",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          adminController.selectedDateStudFrom == null
                              ? "Select Date"
                              : displayDateFormat.format(
                                  adminController.selectedDateStudFrom!),
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (selectedDate != null) {
                              print(selectedDate);
                              adminController
                                  .setSelectedDateStudFrom(selectedDate);

                              // Do something with the selected date
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "To",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          adminController.selectedDateStudTo == null
                              ? "Select Date"
                              : displayDateFormat
                                  .format(adminController.selectedDateStudTo!),
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (selectedDate != null) {
                              print(selectedDate);
                              adminController
                                  .setSelectedDateStudTo(selectedDate);

                              // Do something with the selected date
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                TextButton(
                  onPressed: () async {
                    if (!isNumber(adminController.studentIdController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Student ID must be a number"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (adminController
                            .subjectIdStudController.text.isNotEmpty &&
                        !isNumber(
                            adminController.subjectIdStudController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Subject ID must be a number"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    // if (adminController.selectedDateStud == null) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //       content: Text("Please select a date"),
                    //       backgroundColor: Colors.red,
                    //     ),
                    //   );
                    //   return;
                    // }
                    // await adminController.getDataToDownload(
                    //     0,
                    //     int.parse(adminController.studentIdController.text),
                    //     adminController.selectedDateStud == null
                    //         ? null
                    //         : dateFormat
                    //             .format(adminController.selectedDateStud!),
                    //     adminController.subjectIdStudController.text.isNotEmpty
                    //         ? int.parse(
                    //             adminController.subjectIdStudController.text)
                    //         : null,
                    //     context);
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 50,
                      child: const Text('Download')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool isNumber(String? value) {
    if (value == null) {
      return false;
    }
    final number = int.tryParse(value);
    return number != null;
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String defaultValue,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: defaultValue,
          items: items.map<DropdownMenuItem<String>>(
            (String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            },
          ).toList(),
          onChanged: (String? newValue) {
            onChanged(newValue);
          },
        ),
        Text(label),
      ],
    );
  }

  void _uploadCSV(int table) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      String fileName = result.files.single.name;
      adminController.selectedFiles.add(fileName);
      adminController.selectedFileTable.add(_getTableName(table));
      int length = adminController.uploadStatus.length;
      adminController.setUploadStatus("Uploading");

      setState(() {});

      Uint8List fileBytes = result.files.single.bytes!;

      String endpoint = '';
      switch (table) {
        case 0:
          endpoint = 'csvStudent';
          break;
        case 1:
          endpoint = 'csvSubject';
          break;
        case 2:
          endpoint = 'csvFaculty';
          break;
        case 3:
          endpoint = 'csvSubFac';
          break;
        case 4:
          endpoint = 'csvSubStud';
          break;
        default:
      }

      // Only call addStudentFromCSV for table 0 (Student)
      final blob = html.Blob([fileBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final file = html.File([blob], fileName);

      try {
        final CRUDReturn response =
            await ConfigService.postCsvFile(endpoint, file);

        if (response.success) {
          int index = adminController.uploadStatus.length - 1;
          adminController.setUploadStatus("Success", index);
          switch (table) {
            case 0:
              adminController.getStudents();
              break;
            case 1:
              adminController.getSubjects();
              break;
            case 2:
              adminController.getFaculties();
              break;
            case 4:
              adminController.getSubjectSchedules();
              break;
            default:
          }
        } else {
          int index = adminController.uploadStatus.length - 1;
          adminController.setUploadStatus("Failed", index);
          throw Exception(response.data);
        }

        print('$endpoint File upload response: ${response.toJson()}');
      } catch (e, st) {
        int index = adminController.uploadStatus.length - 1;
        adminController.setUploadStatus("Failed", index);

        print('$endpoint Error uploading file: $e $st');
        // ignore: use_build_context_synchronously
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
                content: const Text(
                    'Upload failed: Please ensure that the CSV format is valid.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } finally {
        html.Url.revokeObjectUrl(url);
      }
    } else {
      print('No file selected.');
    }
  }

  String _getTableName(int table) {
    switch (table) {
      case 0:
        return 'Student';
      case 1:
        return 'Subject';
      case 2:
        return 'Faculty';
      case 3:
        return 'Faculty Subject';
      case 4:
        return 'Student Subject';
      default:
        return 'Student';
    }
  }

  Widget _buildTextButton(String buttonName, VoidCallback onPressed,
      [double width = 130]) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.black54),
      ),
      child: Container(
        width: width,
        height: 80,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          buttonName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildConfig(context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, bottom: 20.0, right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18.0),
            const Text(
              "Term Configurations",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18.0),
            _termInfo(),
            const SizedBox(height: 18.0),
            _timeOffset(),
            const SizedBox(height: 18.0),
            // const Text(
            //   'Reset Password',
            //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 6.0),
            // _resetPasswordForm(),
            // const SizedBox(height: 12.0),
            // Expanded(child: _dataTableClasses(context))
          ],
        ),
      ),
    );
  }

  Widget _mBuildConfig(context) {
    return //add scroll view here
        // adminController.config == null
        //     ? const SizedBox(
        //         height: 50,
        //         width: 50,
        //         child: CircularProgressIndicator(),
        //       )
        //     :
        Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Term Configurations",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          // _mTermInfo(),
          SizedBox(height: 8.0),
          // _mTimeOffset(),
          SizedBox(height: 8.0),
          // Expanded(child: _dataTableClasses(context))
        ],
      ),
    );
  }

  Widget _mTermInfo() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Term Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _showSetTermDialog(context);
                  },
                  child: const Text('Set Term'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _titleText(adminController.config!.currentYear)),
                    const Text('Current Year'),
                  ],
                ),
                const SizedBox(width: 14.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _titleText(adminController.config!.currentYear)),
                    const Text('Current Term'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card _mTimeOffset() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Time Offset',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _showSetOffTimeDialog(context);
                  },
                  child: const Text('Set offset'),
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _titleText(
                            '${adminController.config!.lateMinutes} mins')),
                    const Text('Minutes Late'),
                  ],
                ),
                const SizedBox(width: 18.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _titleText(
                            '${adminController.config!.absentMinutes} mins')),
                    const Text('Minutes Absent'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSetTermDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    String currentTerm = adminController.config!.currentTerm;
    String currentYear = adminController.config!.currentYear;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Term and Year'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    initialValue: adminController.config!.currentYear,
                    decoration: const InputDecoration(
                        labelText: 'Current Year',
                        hintText: '(e.g. 2023-2024)'),
                    validator: (value) {
                      if (!RegExp(r'^\d{4}-\d{4}$').hasMatch(value!)) {
                        return 'Invalid year format';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      currentYear = value;
                      adminController.config!.currentYear = currentYear;
                    },
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    initialValue: adminController.config!.currentTerm,
                    decoration: const InputDecoration(
                        labelText: 'Current Term',
                        hintText: '(e.g. 1st Semester)'),
                    validator: (value) {
                      if (!RegExp(r'^(1st|2nd|3rd) Semester|Tri Semester$')
                          .hasMatch(value!)) {
                        return 'Invalid term format';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      currentTerm = value;
                      adminController.config!.currentTerm = currentTerm;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Save the changes to the AdminController Config
                  // print('adminController.config');
                  print(adminController.config!.toJson());
                  adminController.updateConfig(adminController.config!);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSetOffTimeDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    int lateMinutes = adminController.config!.lateMinutes;
    int absentMinutes = adminController.config!.absentMinutes;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Late and Absent Minutes'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    initialValue:
                        adminController.config!.lateMinutes.toString(),
                    decoration: const InputDecoration(
                        labelText: 'Late Minutes', hintText: '(e.g. 25)'),
                    validator: (value) {
                      if (!RegExp(r'^\d+').hasMatch(value!)) {
                        return 'Invalid minutes format';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      lateMinutes = int.parse(value);
                      adminController.config!.lateMinutes = lateMinutes;
                    },
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    initialValue:
                        adminController.config!.absentMinutes.toString(),
                    decoration: const InputDecoration(
                        labelText: 'Absent Minutes', hintText: '(e.g. 60)'),
                    validator: (value) {
                      if (!RegExp(r'^\d+').hasMatch(value!)) {
                        return 'Invalid minutes format';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      absentMinutes = int.parse(value);
                      adminController.config!.absentMinutes = absentMinutes;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
// Save the changes to the AdminController Config
// You should update the AdminController Config with the new lateMinutes and absentMinutes values
                  adminController.updateConfig(adminController.config!);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Container _termInfo() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Color(0xFFF2F2F2),
            width: 2.0,
          )),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Year and Term',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // const Spacer(),
                TextButton(
                  onPressed: () {
                    _showSetTermDialog(context);
                  },
                  child: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text('Current Year'),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            // _titleText("adminController")),
                            _titleText(adminController.config!.currentYear)),
                  ],
                ),
                const SizedBox(width: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text('Current Term'),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        // child: _titleText("adminController.")),
                        child: _titleText(adminController.config!.currentTerm)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _timeOffset() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Color(0xFFF2F2F2),
            width: 2.0,
          )),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Offset',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _showSetOffTimeDialog(context);
                  },
                  child: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text('Minutes Late'),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            // _titleText('12 mins')),
                            _titleText(
                                '${adminController.config!.lateMinutes} mins')),
                  ],
                ),
                const SizedBox(width: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text('Minutes Absent'),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            // _titleText('12 mins')),
                            _titleText(
                                '${adminController.config!.absentMinutes} mins')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleText(text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  DataColumn customDataColumn({required Widget label, int flex = 1}) {
    return DataColumn(
      label: Expanded(
        flex: flex,
        child: label,
      ),
    );
  }
}
