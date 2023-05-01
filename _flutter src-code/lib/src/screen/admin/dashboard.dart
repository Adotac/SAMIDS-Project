import 'dart:io';
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../controllers/admin_controller.dart';
import '../../services/DTO/crud_return.dart';
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

  List<String> selectedFiles = [];
  List<String> selectedFileTable = [];
  List<String> uploadStatus = [];
  @override
  void initState() {
    adminController.getConfig();
    adminController.getStudents();
    adminController.getAttendanceAll(null);
    adminController.getFaculties();
    super.initState();
  }

  bool isMobile(BoxConstraints constraints) {
    return (constraints.maxWidth <= 450);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
      if (isMobile(constraints)) {
        return _mobileView();
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
          body: _webDashboardBody(),
        );
      },
    );
  }

  Widget _mobileView() {
    return AnimatedBuilder(
      animation: adminController,
      builder: (context, child) {
        return MobileView(
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildConfig(context),
          ),
          const VerticalDivider(width: 32.0),
          Expanded(
            child: _buildUpload(),
          ),
          const VerticalDivider(width: 32.0),
          Expanded(
            child: _buildDownloadCSV(),
          )
        ],
      ),
    );
  }

  // Widget _mBuildUpload() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 12.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Upload CSV',
  //           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 16.0),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 _buildTextButton('Student', () => _uploadCSV(0)),
  //                 const SizedBox(width: 8.0),
  //                 _buildTextButton('Subject', () => _uploadCSV(1)),
  //                 const SizedBox(width: 8.0),
  //                 _buildTextButton('Faculty', () => _uploadCSV(2)),
  //               ],
  //             ),
  //             const SizedBox(height: 8.0),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 _buildTextButton('Faculty Subject', () => _uploadCSV(3)),
  //                 const SizedBox(width: 8.0),
  //                 _buildTextButton('Student Subject', () => _uploadCSV(4)),
  //               ],
  //             ),

  //           ],
  //         ),
  //         const SizedBox(height: 16.0),
  //         Card(
  //           elevation: 0,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12.0),
  //           ),
  //           child: SingleChildScrollView(
  //             scrollDirection: Axis.horizontal,
  //             child: SizedBox(
  //               width: MediaQuery.of(context).size.width * .95,
  //               child: DataTable(
  //                 columns: const [
  //                   DataColumn(label: Text('File Name')),
  //                   DataColumn(label: Text('Table Selected')),
  //                   DataColumn(label: Text('Status')),
  //                 ],
  //                 rows: List.generate(
  //                   selectedFiles.length,
  //                   (index) => DataRow(
  //                     cells: [
  //                       DataCell(Text(selectedFiles[index])),
  //                       DataCell(SingleChildScrollView(
  //                           child: Text(selectedFileTable[index]))),
  //                       const DataCell(Text('Uploading...')),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload CSV',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTextButton('Student', () => _uploadCSV(0)),
            _buildTextButton('Subject', () => _uploadCSV(1)),
            _buildTextButton('Faculty', () => _uploadCSV(2)),
            _buildTextButton('Faculty Subject', () => _uploadCSV(3)),
            _buildTextButton('Student Subject', () => _uploadCSV(4)),
          ],
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('File Name')),
                    DataColumn(label: Text('Table Selected')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: List.generate(
                    selectedFiles.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text(selectedFiles[index])),
                        DataCell(Text(selectedFileTable[index])),
                        // ignore: unrelated_type_equality_checks
                        DataCell(Text(adminController.uploadStatus[index],
                            style: TextStyle(
                                color: adminController.uploadStatus[index] ==
                                        'Failed'
                                    ? Theme.of(context).colorScheme.error
                                    : Colors.green))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadCSV() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Download Attendance CSV',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        _downloadForm(),
        const SizedBox(height: 18.0),
        const Text(
          'Reset Password',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        _resetPasswordForm(),
      ],
    );
  }

  Widget _mBuildDownloadCSV() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Download Attendance CSV',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          _mDownloadForm(),
          const SizedBox(height: 18.0),
          const Text(
            'Reset Password',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
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

  Card _mDownloadForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Year - Term",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildDropdownField(
              label: "Current Year - Current Term",
              items: ["2022-2023 2nd Semester"],
              defaultValue: "2022-2023 2nd Semester",
            ),
            const Divider(),
            const SizedBox(
              height: 18,
            ),
            const Text(
              "From Faculty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: "Select Faculty",
                    items: ["All", "Faculty A", "Faculty B"],
                    defaultValue: "All",
                  ),
                ),
                Expanded(
                  child: _buildDropdownField(
                    label: "Select Subject",
                    items: ["All", "Subject A", "Subject B"],
                    defaultValue: "All",
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 12.0),
              child: TextButton(
                onPressed: () {},
                child: const Text('Download'),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Divider(),
            const Text(
              "From Attendance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: "Select Student",
                    items: ["All", "Student A", "Student B"],
                    defaultValue: "All",
                  ),
                ),
                Expanded(
                  child: _buildDropdownField(
                    label: "Select Subject",
                    items: ["All", "Subject A", "Subject B"],
                    defaultValue: "All",
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 12.0),
              child: TextButton(
                onPressed: () {},
                child: const Text('Download'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Card _downloadForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Year - Term",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildDropdownField(
              label: "Current Year - Current Term",
              items: ["2022-2023 2nd Semester"],
              defaultValue: "2022-2023 2nd Semester",
            ),
            const Divider(),
            const SizedBox(
              height: 18,
            ),
            const Text(
              "From Faculty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: "Select Faculty",
                    items: ["All", "Faculty A", "Faculty B"],
                    defaultValue: "All",
                  ),
                ),
                Expanded(
                  child: _buildDropdownField(
                    label: "Select Subject",
                    items: ["All", "Subject A", "Subject B"],
                    defaultValue: "All",
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 12.0),
              child: TextButton(
                onPressed: () {},
                child: const Text('Download'),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Divider(),
            const Text(
              "From Attendance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: "Select Student",
                    items: ["All", "Student A", "Student B"],
                    defaultValue: "All",
                  ),
                ),
                Expanded(
                  child: _buildDropdownField(
                    label: "Select Subject",
                    items: ["All", "Subject A", "Subject B"],
                    defaultValue: "All",
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 12.0),
              child: TextButton(
                onPressed: () {},
                child: const Text('Download'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String defaultValue,
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
          onChanged: (String? newValue) {},
        ),
        Text(label),
      ],
    );
  }

  // Widget _buildDownload() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Download CSV',
  //         style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 16.0),
  //       Expanded(
  //         child: Card(
  //           elevation: 0,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12.0),
  //           ),
  //           child: SingleChildScrollView(
  //             scrollDirection: Axis.horizontal,
  //             child: SizedBox(
  //               width: MediaQuery.of(context).size.width * 0.3,
  //               child: DataTable(
  //                 columns: const [
  //                   DataColumn(label: Text('File Name')),
  //                   DataColumn(label: Text('Table Selected')),
  //                   DataColumn(label: Text('Status')),
  //                 ],
  //                 rows: List.generate(
  //                   selectedFiles.length,
  //                   (index) => DataRow(
  //                     cells: [
  //                       DataCell(Text(selectedFiles[index])),
  //                       DataCell(Text(selectedFileTable[index])),
  //                       DataCell(Text(adminController.uploadStatus[index])),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  void _uploadCSV(int table) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      String fileName = result.files.single.name;
      selectedFiles.add(fileName);
      selectedFileTable.add(_getTableName(table));
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
                content: Text('Failed to upload file: $e'),
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

  Widget _buildTextButton(String buttonName, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          Theme.of(context).primaryColor,
        ),
        foregroundColor: MaterialStateProperty.all<Color>(
          Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      child: Text(buttonName),
    );
  }

  Widget _buildConfig(context) {
    return adminController.config == null
        ? const SizedBox(
            height: 500,
            child: CircularProgressIndicator(),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Configurations",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14.0),
              _termInfo(),
              const SizedBox(height: 14.0),
              _timeOffset(),
              // const SizedBox(height: 12.0),
              // Expanded(child: _dataTableClasses(context))
            ],
          );
  }

  Widget _mBuildConfig(context) {
    return //add scroll view here
        adminController.config == null
            ? const SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              )
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Configurations",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    _mTermInfo(),
                    const SizedBox(height: 8.0),
                    _mTimeOffset(),
                    const SizedBox(height: 8.0),
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
                    _showSetOfftimeDialog(context);
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
                  print('adminController.config');
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

  Future<void> _showSetOfftimeDialog(BuildContext context) async {
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

  Card _termInfo() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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
            const SizedBox(height: 18.0),
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
                const SizedBox(width: 24.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _titleText(adminController.config!.currentTerm)),
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

  Card _timeOffset() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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
                    _showSetOfftimeDialog(context);
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
                const SizedBox(width: 24.0),
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

  Widget _titleText(text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  List<Map<String, dynamic>> sampleStudentClasses = [
    {
      'subject': 'Data Structures and Algorithms',
      'room': 'BCL1',
      'timeStart': DateTime(2023, 4, 1, 5, 30),
      'timeEnd': DateTime(2023, 4, 1, 6, 30),
      'day': 'Mon, Wed, Fri',
    },
    {
      'subject': 'Operating Systems',
      'room': 'BCL2',
      'timeStart': DateTime(2023, 4, 1, 10, 0),
      'timeEnd': DateTime(2023, 4, 1, 11, 30),
      'day': 'Tue, Thu',
    },
    {
      'subject': 'Design and Analysis of Algorithms',
      'room': 'BCL3',
      'timeStart': DateTime(2023, 4, 1, 2, 0),
      'timeEnd': DateTime(2023, 4, 1, 3, 30),
      'day': 'Mon, Wed, Fri',
    },
    {
      'subject': 'Natural Language Processing',
      'room': 'BCL4',
      'timeStart': DateTime(2023, 4, 1, 13, 0),
      'timeEnd': DateTime(2023, 4, 1, 14, 30),
      'day': 'Tue, Thu',
    },
    {
      'subject': 'Programming Languages',
      'room': 'BCL5',
      'timeStart': DateTime(2023, 4, 1, 16, 0),
      'timeEnd': DateTime(2023, 4, 1, 17, 30),
      'day': 'Mon, Wed, Fri',
    },
    // {
    //   'subject': 'Calculus',
    //   'room': 'BCL6',
    //   'timeStart': DateTime(2023, 4, 1, 8, 0),
    //   'timeEnd': DateTime(2023, 4, 1, 9, 30),
    //   'day': 'Tue, Thu',
    // },
    {
      'subject': 'Machine Learning',
      'room': 'BCL7',
      'timeStart': DateTime(2023, 4, 1, 14, 30),
      'timeEnd': DateTime(2023, 4, 1, 16, 0),
      'day': 'Mon, Wed, Fri',
    },
    // {
    //   'subject': 'Apps Development 2',
    //   'room': 'BCL8',
    //   'timeStart': DateTime(2023, 4, 1, 9, 0),
    //   'timeEnd': DateTime(2023, 4, 1, 10, 30),
    //   'day': 'Tue, Thu',
    // },
    // {
    //   'subject': 'Software Engineering 2',
    //   'room': 'BCL9',
    //   'timeStart': DateTime(2023, 4, 1, 11, 0),
    //   'timeEnd': DateTime(2023, 4, 1, 12, 30),
    //   'day': 'Mon, Wed, Fri',
    // },
  ];

  Widget _dataTableClasses(context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: SingleChildScrollView(
          child: DataTable(columns: [
            customDataColumn(label: const Text('Year'), flex: 3),
            customDataColumn(label: const Text('Term  '), flex: 1),
          ], rows: _buildSampleDataRows(context)),
        ),
      ),
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

  List<DataRow> _buildSampleDataRows(BuildContext context) {
    return sampleStudentClasses.map((schedule) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              schedule['subject'],
              style: const TextStyle(fontSize: 14),
            ),
          ),
          DataCell(
            Text(
              '${schedule['timeStart'].hour == 0 ? 12 : (schedule['timeStart'].hour < 13 ? schedule['timeStart'].hour : schedule['timeStart'].hour - 12).toString().padLeft(2, '0')}:${schedule['timeStart'].minute.toString().padLeft(2, '0')} ${schedule['timeStart'].hour < 12 ? 'AM' : 'PM'} - ${(schedule['timeEnd'].hour == 0 ? 12 : (schedule['timeEnd'].hour < 13 ? schedule['timeEnd'].hour : schedule['timeEnd'].hour - 12)).toString().padLeft(2, '0')}:${schedule['timeEnd'].minute.toString().padLeft(2, '0')} ${schedule['timeEnd'].hour < 12 ? 'AM' : 'PM'}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
