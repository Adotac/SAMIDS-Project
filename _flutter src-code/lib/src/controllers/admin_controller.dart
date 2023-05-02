//faculty
//75779

import 'dart:convert';
import 'dart:html';
import 'dart:io' as io;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'package:samids_web_app/src/model/attendance_model.dart';
import 'package:samids_web_app/src/model/student_model.dart';

import 'package:samids_web_app/src/model/subjectSchedule_model.dart';
import 'package:samids_web_app/src/model/subject_model.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/attendance.services.dart';
import '../model/config_model.dart';
import '../model/faculty_model.dart';
import '../services/config.services.dart';
import '../services/faculty.services.dart';
import '../services/student.services.dart';

class AdminController with ChangeNotifier {
  List<String> selectedFiles = [];
  List<String> selectedFileTable = [];
  List<String> uploadStatus = [];

  List<Attendance> attendance = [];
  List<Attendance> allAttendanceList = [];
  List<SubjectSchedule> studentClasses = [];
  List<Attendance> filteredAttendanceList = [];
  List<Student> students = [];
  String selectedUserType = 'Student';
  List<Faculty> filteredFaculties = [];

  DateTime? selectedDateStud;
  DateTime? selectedDateFac;

  bool isStudentClassesCollected = false;
  bool isCountCalculated = false;
  bool isAttendanceTodayCollected = false;
  bool isAllAttendanceCollected = false;
  bool sortAscending = true;
  bool sortAscendingStudent = true;

  String sortColumn = "";
  String currentYear = '';
  String currentTerm = '';
  String sortColumnStudent = "";
  String lateMinutes = '';
  String absentMinutes = '';

  String sortColumnFaculties = '';
  bool sortAscendingFaculties = true;
  final Logger _logger = Logger();

  final facultyIdController = TextEditingController();
  final subjectIdFacController = TextEditingController();
  final studentIdController = TextEditingController();
  final subjectIdStudController = TextEditingController();

  static AdminController get I => GetIt.instance<AdminController>();
  static AdminController get instance => GetIt.instance<AdminController>();
  static void initialize() {
    GetIt.instance.registerSingleton<AdminController>(AdminController());
  }

  void clearList() {
    selectedFiles.clear();
    selectedFileTable.clear();
    uploadStatus.clear();

    notifyListeners();
  }

  void setSelectedDateStud(DateTime date) {
    selectedDateStud = date;
    notifyListeners();
  }

  void setSelectedDateFac(DateTime date) {
    selectedDateFac = date;
    notifyListeners();
  }

  void setSelectedUserType(String userType) {
    selectedUserType = userType;
    notifyListeners();
  }

  void setUploadStatus(String message, [int index = -1]) {
    if (index != -1) {
      uploadStatus[index] = message;
    } else {
      uploadStatus.add(message);
    }
    notifyListeners();
  }

  void filterAttendance(String query) {
    if (query.isEmpty) {
      filteredAttendanceList = allAttendanceList;
      attendanceListToDownload = filteredAttendanceList;
    } else {
      filteredAttendanceList = allAttendanceList.where((attendance) {
        final studentNo = attendance.student?.studentNo.toString() ?? '';
        final firstName = attendance.student?.firstName.toLowerCase() ?? '';
        final lastName = attendance.student?.lastName.toLowerCase() ?? '';
        final subjectName =
            attendance.subjectSchedule?.subject?.subjectName.toLowerCase() ??
                '';

        final room = attendance.subjectSchedule?.room.toLowerCase() ?? '';
        final remarks = attendance.remarks.name.toLowerCase();
        return firstName.contains(query.toLowerCase()) ||
            studentNo.toString() == query ||
            lastName.contains(query.toLowerCase()) ||
            subjectName.contains(query.toLowerCase()) ||
            room.contains(query.toLowerCase()) ||
            remarks.contains(query.toLowerCase());
      }).toList();
    }
    attendanceListToDownload = filteredAttendanceList;
    notifyListeners();
  }

  logout() {
    isStudentClassesCollected = false;
    isCountCalculated = false;
    isAttendanceTodayCollected = false;
    isAllAttendanceCollected = false;

    attendance.clear();
    allAttendanceList.clear();
    studentClasses.clear();
  }

  Config? config;

  void handleEventJsonConfig(CRUDReturn result) {
    try {
      if (result.data.isNotEmpty) {
        config = Config.fromJson(result.data);
      }
      notifyListeners();
    } catch (e, stacktrace) {
      print('handleEventJsonConfig $e $stacktrace');
    }
  }

  Future<void> getAttendanceAll(String? date) async {
    try {
      if (isAllAttendanceCollected) return;

      CRUDReturn response = date != null
          ? await AttendanceService.getAll(
              date: date,
            )
          : await AttendanceService.getAll();
      if (response.success) {
        await handEventJsonAttendanceAll(response);
        isAllAttendanceCollected = true;
        notifyListeners();
      }
    } catch (e, stacktrace) {
      _logger.i('adminController getAttendanceAll $e $stacktrace');
    }
  }

  bool isEditingFaculty = false;
  Future<void> onUpdateFaculty(
      int facultyNo, String firstName, String lastName) async {
    try {
      isEditingFaculty = true;
      notifyListeners();

      await FacultyService.updateFaculty(facultyNo, firstName, lastName);
      await getFaculties();

      isEditingFaculty = false;
      notifyListeners();
    } catch (e, stacktrace) {
      _logger.i('onUpdateFaculty onUpdateFaculty $e $stacktrace');
    }
  }

  Future<void> getConfig() async {
    try {
      CRUDReturn response = await ConfigService.getConfig();
      if (response.success) {
        handleEventJsonConfig(response);
      }
    } catch (e, stacktrace) {
      print('adminController getConfig $e $stacktrace');
    }
  }

  void _handleEventJsonStudent(CRUDReturn result) {
    try {
      if (result.data.isNotEmpty) {
        students = List<Student>.from(
          result.data.map((studentJson) => Student.fromJson(studentJson)),
        );
      }
      notifyListeners();
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print('handleEventJsonStudent $e $stacktrace');
      }
    }
  }

  Future<void> getStudents() async {
    try {
      CRUDReturn response = await StudentService.getStudents();
      if (response.success) {
        _handleEventJsonStudent(response);
      }
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print('StudentController getStudents $e $stacktrace');
      }
    }
  }

  void sortAttendance(String column) {
    sortAscending = sortColumn == column ? !sortAscending : true;
    sortColumn = column;

    int order = sortAscending ? 1 : -1;

    switch (column) {
      case "Student ID":
        filteredAttendanceList.sort((a, b) =>
            order *
            (a.student?.studentNo.compareTo(b.student?.studentNo ?? 0) ?? 0));
        break;
      case "Name":
        filteredAttendanceList.sort((a, b) {
          int compare =
              a.student?.lastName.compareTo(b.student?.lastName ?? '') ?? 0;
          if (compare == 0) {
            compare =
                a.student?.firstName.compareTo(b.student?.firstName ?? '') ?? 0;
          }
          return order * compare;
        });
        break;
      case "Reference ID":
        filteredAttendanceList
            .sort((a, b) => order * a.attendanceId.compareTo(b.attendanceId));
        break;
      case "Room":
        filteredAttendanceList.sort((a, b) =>
            order *
            (a.subjectSchedule?.room.compareTo(b.subjectSchedule?.room ?? '') ??
                0));
        break;
      case "Subject":
        filteredAttendanceList.sort((a, b) =>
            order *
            (a.subjectSchedule?.subject?.subjectName
                    .compareTo(b.subjectSchedule?.subject?.subjectName ?? '') ??
                0));
        break;
      case "Day":
        filteredAttendanceList.sort((a, b) =>
            order *
            (a.subjectSchedule?.day.index as num)
                .compareTo(b.subjectSchedule?.day.index as num));
        break;
      case "Date":
        filteredAttendanceList.sort((a, b) =>
            order * (a.date?.compareTo(b.date ?? DateTime.now()) ?? 0));
        break;
      case "Time In":
        filteredAttendanceList.sort((a, b) =>
            order *
            (a.actualTimeIn?.hour.compareTo(b.actualTimeIn?.hour ?? 0) ?? 0));
        break;
      case "Time Out":
        filteredAttendanceList.sort((a, b) =>
            order *
            (a.actualTimeOut?.hour.compareTo(b.actualTimeOut?.hour ?? 0) ?? 0));
        break;
      case "Remarks":
        filteredAttendanceList
            .sort((a, b) => order * a.remarks.index.compareTo(b.remarks.index));
        break;
    }

    notifyListeners();
  }

  String _searchQueryStudent = '';

  void searchStudents(String query) {
    _searchQueryStudent = query;
    notifyListeners();
  }

  List<Student> get filteredStudents {
    if (_searchQueryStudent.isEmpty) {
      return students;
    } else {
      return students
          .where((student) =>
              student.lastName
                  .toLowerCase()
                  .contains(_searchQueryStudent.toLowerCase()) ||
              student.firstName
                  .toLowerCase()
                  .contains(_searchQueryStudent.toLowerCase()))
          .toList();
    }
  }

  Future<void> updateConfig(Config newConfig) async {
    try {
      CRUDReturn response = await ConfigService.updateConfig(newConfig);
      if (response.success) {
        handleEventJsonConfig(response);
      }
    } catch (e, stacktrace) {
      print('ConfigController updateConfig $e $stacktrace');
    }
  }

  handEventJsonAttendance(CRUDReturn result) {
    if (attendance.isNotEmpty) attendance.clear();
    for (Map<String, dynamic> map in result.data) {
      attendance.add(Attendance.fromJson(map));
    }

    isAttendanceTodayCollected = true;
    notifyListeners();
  }

  handEventJsonAttendanceAll(CRUDReturn result) {
    if (allAttendanceList.isNotEmpty) allAttendanceList.clear();

    for (Map<String, dynamic> map in result.data) {
      allAttendanceList.add(Attendance.fromJson(map));
    }
    filteredAttendanceList = allAttendanceList;
    attendanceListToDownload = allAttendanceList;
    notifyListeners();
  }

  void handleEventJsonStudentClasses(CRUDReturn result) {
    try {
      if (studentClasses.isNotEmpty) studentClasses.clear();
      for (Map<String, dynamic> map in result.data) {
        studentClasses.add(SubjectSchedule.fromJson(map));
      }
      isStudentClassesCollected = true;
      notifyListeners();
    } catch (e, stacktrace) {
      print('handleEventJsonStudentClasses $e $stacktrace');
    }
  }

  String formatTime(DateTime dateTime) {
    final formattedTime = DateFormat('hh:mm a').format(dateTime);
    return formattedTime;
  }

  String formatDate(DateTime dateTime) {
    final formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
    return formattedDate;
  }

  Color getStatusColor(Remarks remarks, BuildContext context) {
    switch (remarks) {
      case Remarks.onTime:
        return Colors.green; // Modify with the desired color for onTime
      case Remarks.late:
        return Colors.orange; // Modify with the desired color for late
      case Remarks.cutting:
        return Colors
            .yellow.shade700; // Modify with the desired color for cutting
      case Remarks.absent:
        return Colors.red
            .withOpacity(0.5); // Modify with the desired color for absent
    }
  }

  Text getStatusText(String status) {
    final String lowercaseStatus = status.toLowerCase();
    Color color;
    String text = '';
    switch (lowercaseStatus) {
      case 'absent':
        color = Colors.red;
        text = 'Absent';
        break;
      case 'cutting':
        color = Colors.yellow.shade700;
        text = 'Cutting';
        break;
      case 'ontime':
        color = Colors.green;
        text = 'On Time';
        break;
      case 'late':
        color = Colors.orange;
        text = 'Late';
        break;
      default:
        color = Colors.black;
        text = 'Unknown';
        break;
    }
    return Text(
      text,
      style: TextStyle(color: color),
    );
  }

  void sortStudents(String column) {
    if (sortColumnStudent == column) {
      sortAscendingStudent = !sortAscendingStudent;
    } else {
      sortColumnStudent = column;
      sortAscendingStudent = true;
    }

    students.sort((a, b) {
      int compare;
      switch (column) {
        case 'Student No':
          compare = a.studentNo.compareTo(b.studentNo);
          break;
        case 'RFID':
          compare = a.rfid.compareTo(b.rfid);
          break;
        case 'Last Name':
          compare = a.lastName.compareTo(b.lastName);
          break;
        case 'First Name':
          compare = a.firstName.compareTo(b.firstName);
          break;
        case 'Year':
          compare = a.year.toString().compareTo(b.year.toString());
          break;
        default:
          compare = 0;
      }
      return sortAscendingStudent ? compare : -compare;
    });

    notifyListeners();
  }

  void handleEventJsonFaculty(CRUDReturn result) {
    try {
      if (filteredFaculties.isNotEmpty) filteredFaculties.clear();

      if (result.data.isNotEmpty) {
        for (Map<String, dynamic> map in result.data) {
          filteredFaculties.add(Faculty.fromJson(map));
        }
      }

      notifyListeners();
    } catch (e, stacktrace) {
      print('handleEventJsonFaculty $e $stacktrace');
    }
  }

  Future<void> getFaculties() async {
    try {
      CRUDReturn response = await FacultyService.getFaculties();
      if (response.success) {
        print('response.success');
        handleEventJsonFaculty(response);
      }
    } catch (e, stacktrace) {
      print(' getFaculties $e $stacktrace');
    }
  }

  void searchFaculties(String query) {
    if (query.isEmpty) {
      filteredFaculties = filteredFaculties;
      notifyListeners();
      return;
    }
    filteredFaculties = filteredFaculties
        .where((faculty) =>
            faculty.facultyNo.toString().contains(query) ||
            faculty.firstName.toLowerCase().contains(query.toLowerCase()) ||
            faculty.lastName.toLowerCase().contains(query.toLowerCase()) ||
            faculty.facultyNo.toString().contains(query))
        .toList();
    notifyListeners();
  }

  void sortFaculties(String column) {
    if (sortColumnFaculties == column) {
      sortAscendingFaculties = !sortAscendingFaculties;
    } else {
      sortColumnFaculties = column;
      sortAscendingFaculties = true;
    }

    filteredFaculties.sort((a, b) {
      int compare;
      switch (column) {
        case 'Faculty No':
          compare = a.facultyNo.compareTo(b.facultyNo);
          break;
        case 'Last Name':
          compare = a.lastName.compareTo(b.lastName);
          break;
        case 'First Name':
          compare = a.firstName.compareTo(b.firstName);
          break;
        default:
          compare = 0;
      }
      return sortAscendingFaculties ? compare : -compare;
    });

    notifyListeners();
  }

  List<Attendance> attendanceListToDownload = [];

  handEventJsonAttendanceAllDownload(CRUDReturn result) {
    if (allAttendanceList.isNotEmpty) allAttendanceList.clear();

    for (Map<String, dynamic> map in result.data) {
      attendanceListToDownload.add(Attendance.fromJson(map));
    }
    filteredAttendanceList = allAttendanceList;
    notifyListeners();
  }

  String userTypeName = 'Attendance';
  int userId = 0;

  Future<void> getDataToDownload(
      int type, int? userNo, String? date, int? schedId, context) async {
    CRUDReturn response;
    try {
      userTypeName = type == 0 ? 'Student' : 'Faculty';
      userId = userNo ?? 0;
      if (type == 0) {
        response = await AttendanceService.getAll(
          studentNo: userNo,
          schedId: schedId,
          date: date,
        );
      } else {
        response = await AttendanceService.getAll(
          facultyNo: userNo,
          schedId: schedId,
          date: date,
        );
      }

      if (response.success) {
        handEventJsonAttendanceAllDownload(response);
        downloadData(context);
      }
    } catch (e, stacktrace) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error', style: TextStyle(color: Colors.red)),
            content: Text(
              '$e',
              overflow: TextOverflow.ellipsis,
            ),
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
      print('StudentDashboardController getAttendanceAll $e $stacktrace');
    }
  }

  bool sortAscendingSub = true;

  String sortColumnSub = '';

  void sortSubjects(String column) {
    if (sortColumnSub == column) {
      sortAscendingSub = !sortAscendingSub;
    } else {
      sortColumnSub = column;
      sortAscendingSub = true;
    }

    filteredSubjects.sort((a, b) {
      int compare;
      switch (column) {
        case 'Subject ID':
          compare = a.subjectID.compareTo(b.subjectID);
          break;
        case 'Subject Name':
          compare = a.subjectName.compareTo(b.subjectName);
          break;
        case 'Subject Description':
          compare = a.subjectDescription.compareTo(b.subjectDescription);
          break;
        default:
          compare = 0;
      }
      return sortAscendingSub ? compare : -compare;
    });

    notifyListeners();
  }

  Future<void> downloadData(context) async {
    if (attendanceListToDownload.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('No attendance data found'),
            content: Text('There is no attendance data to download.'),
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
      return;
    }

    List<List<dynamic>> csvData = [
      // Add headers to the CSV file
      [
        "Student ID",
        "Name",
        "Reference ID",
        "Room",
        "Subject",
        "Date",
        "Day",
        "Time in",
        "Time out",
        "Remarks"
      ],
    ];

    for (Attendance attendance in attendanceListToDownload) {
      List<dynamic> row = [
        attendance.student?.studentNo ?? '',
        '${attendance.student?.firstName ?? ''} ${attendance.student?.lastName ?? ''}',
        attendance.attendanceId,
        attendance.subjectSchedule?.room ?? '',
        attendance.subjectSchedule?.subject?.subjectName ?? '',
        attendance.date?.toIso8601String() ?? '',
        attendance.subjectSchedule?.day?.toString() ?? '',
        attendance.actualTimeIn?.hour.toString() ?? '',
        attendance.actualTimeOut?.hour.toString() ?? '',
        attendance.remarks.index,
      ];
      csvData.add(row);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    String fileName = "${userTypeName}_${userId}_${DateTime.now()}";
    if (kIsWeb) {
      // Web implementation
      AnchorElement(href: "data:text/csv;charset=utf-8,$csv")
        ..setAttribute("download", "$fileName.csv")
        ..click();
    } else {
// Mobile implementation
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = io.File('$path/attendance_data.csv');
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV file saved to: ${file.path}')),
      );
    }
  }

  void attendanceReset() {
    filteredAttendanceList = allAttendanceList;
    attendanceListToDownload = allAttendanceList;
    notifyListeners();
  }

  List<Subject> _allSubjects = [];
  List<Subject> _filteredSubjects = [];

  List<Subject> get allSubjects => _allSubjects;
  List<Subject> get filteredSubjects => _filteredSubjects;

  bool _isSubjectCollected = false;
  bool get isSubjectCollected => _isSubjectCollected;

  Future<void> getSubjects() async {
    try {
      if (_isSubjectCollected) return;

      final response = await ConfigService.getSubjects();
      if (response.success) {
        _allSubjects = response.data
            .map<Subject>((json) => Subject.fromJson(json))
            .toList();
        _filteredSubjects = _allSubjects;
        _isSubjectCollected = true;
        notifyListeners();
      }
    } catch (e, stacktrace) {
      debugPrint('SubjectController getSubjects $e $stacktrace');
    }
  }

  void filterSubjects(String query) {
    if (query.isNotEmpty) {
      _filteredSubjects = _allSubjects
          .where((subject) =>
              subject.subjectName.toLowerCase().contains(query.toLowerCase()) ||
              subject.subjectID.toString().contains(query.toLowerCase()) ||
              subject.subjectDescription
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    } else {
      _filteredSubjects = _allSubjects;
    }
    notifyListeners();
  }
}
