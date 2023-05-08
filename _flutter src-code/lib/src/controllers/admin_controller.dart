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
import 'package:samids_web_app/src/services/DTO/add_faculty.dart';
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

  List<Attendance> allAttendanceList = [];
  List<SubjectSchedule> studentClasses = [];

  List<SubjectSchedule> filteredSubjectSchedule = [];

  List<Attendance> filteredAttendanceList = [];
  List<Student> students = [];
  List<Student> studentsTemp = [];
  String selectedUserType = 'Student';
  List<Faculty> filteredFaculties = [];

  DateTime? selectedDateStudFrom;
  DateTime? selectedDateStudTo;
  DateTime? selectedDateFacFrom;
  DateTime? selectedDateFacTo;

  bool isStudentClassesCollected = false;
  bool isCountCalculated = false;
  bool isAttendanceTodayCollected = false;
  bool isAllAttendanceCollected = false;
  bool sortAscending = true;
  bool sortAscendingStudent = true;
  bool isGettingClasses = false;
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

  Student? selectedStudent;

  Faculty? selectedFaculty;
  Faculty? tempFaculty;
  void clearList() {
    selectedFiles.clear();
    selectedFileTable.clear();
    uploadStatus.clear();

    notifyListeners();
  }

  void setSelectedDateStudFrom(DateTime date) {
    selectedDateStudFrom = date;
    notifyListeners();
  }

  void setSelectedDateFacFrom(DateTime date) {
    selectedDateFacFrom = date;
    notifyListeners();
  }

  void setSelectedDateStudTo(DateTime date) {
    selectedDateStudTo = date;
    notifyListeners();
  }

  void setSelectedDateFacTo(DateTime date) {
    selectedDateFacTo = date;
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

  void handleJsonSubjectSchedules(List<SubjectSchedule> subjectSchedulesList) {
    try {
      if (filteredSubjectSchedules.isNotEmpty) filteredSubjectSchedules.clear();

      if (subjectSchedulesList.isNotEmpty) {
        filteredSubjectSchedules.addAll(subjectSchedulesList);
        subjectSchedules.addAll(subjectSchedulesList);
      }

      notifyListeners();
    } catch (e, stacktrace) {
      print('handleJsonSubjectSchedules $e $stacktrace');
    }
  }

  void sortAscendingSubjectSchedules(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }

    filteredSubjectSchedules.sort((a, b) {
      int compare;
      switch (column) {
        case 'Subject Id':
          compare =
              a.subject?.subjectID.compareTo(b.subject?.subjectID ?? 0) ?? 0;
          break;
        case 'Code':
          compare =
              a.subject?.subjectName.compareTo(b.subject?.subjectName ?? '') ??
                  0;
          break;
        case 'Description':
          compare = a.subject?.subjectDescription
                  .compareTo(b.subject?.subjectDescription ?? '') ??
              0;
          break;
        case 'Room':
          compare = a.room.compareTo(b.room);
          break;
        case 'Time Start':
          compare = a.timeStart.compareTo(b.timeStart);
          break;
        case 'Time End':
          compare = a.timeEnd.compareTo(b.timeEnd);
          break;
        case 'Day':
          compare = a.day.compareTo(b.day);
          break;
        default:
          compare = 0;
      }
      return sortAscending ? compare : -compare;
    });

    notifyListeners();
  }

  void filterSubjectSchedule(String query) {
    if (query.isEmpty) {
      filteredSubjectSchedules = subjectSchedules;
      notifyListeners();
      return;
    }
    filteredSubjectSchedules = subjectSchedules
        .where((subject) =>
            subject.subject!.subjectName
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            subject.subject!.subjectDescription
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            subject.room.toLowerCase().contains(query.toLowerCase()) ||
            subject.day.toLowerCase().contains(query.toLowerCase()) ||
            subject.schedId.toString().contains(query) ||
            subject.timeStart.toString().contains(query) ||
            subject.timeEnd.toString().contains(query))
        .toList();
    notifyListeners();
  }

  Future<void> getSubjectSchedules() async {
    try {
      List<SubjectSchedule> subjectSchedulesList =
          await ConfigService.getSubjectSchedules();
      handleJsonSubjectSchedules(subjectSchedulesList);
    } catch (e, stacktrace) {
      print('getSubjectSchedules $e $stacktrace');
    }
  }

  List<SubjectSchedule> subjectSchedules = [];
  List<SubjectSchedule> filteredSubjectSchedules = [];
  String sortColumnSubjectSchedules = '';
  // bool sortAscendingSubjectSchedules = true;

  // void sortSubjectSchedules(String column) {
  //   if (sortColumnSubjectSchedules == column) {
  //     sortAscendingSubjectSchedules = !sortAscendingSubjectSchedules;
  //   } else {
  //     sortColumnSubjectSchedules = column;
  //     sortAscendingSubjectSchedules = true;
  //   }

  //   notifyListeners();
  // }

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
        // final remarks = attendance.remarks.name.toLowerCase();
        return firstName.contains(query.toLowerCase()) ||
            studentNo.toString() == query ||
            lastName.contains(query.toLowerCase()) ||
            subjectName.contains(query.toLowerCase()) ||
            room.contains(query.toLowerCase());
        // remarks.contains(query.toLowerCase());
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
      } else {
        _logger.i('adminController else ${response.data}');
      }
    } catch (e, stacktrace) {
      _logger.i('adminController getAttendanceAll $e $stacktrace');
    }
  }

  void handleEventJsonFacultySingle(CRUDReturn result) {
    try {
      if (result.data.isNotEmpty) {
        tempFaculty = Faculty.fromJson(result.data);
      }
      notifyListeners();
    } catch (e, stacktrace) {
      _logger.i('handleEventJsonFaculty $e $stacktrace');
    }
  }

  Future<void> getFacultyById(int id) async {
    try {
      CRUDReturn response = await FacultyService.getFacultyById(id);
      if (response.success) {
        handleEventJsonFacultySingle(response);
      }
    } catch (e, stacktrace) {
      _logger.i('adminController getFacultyById $e $stacktrace');
    }
  }

  Future<void> addNewFaculty(
      String id, String firstName, String lastName) async {
    await onUpdateFaculty(int.parse(id), firstName, lastName);
  }

  bool isEditingFaculty = false;
  Future<void> onUpdateFaculty(
      int facultyNo, String firstName, String lastName) async {
    try {
      isEditingFaculty = true;
      notifyListeners();

      await FacultyService.addFaculty(facultyNo, firstName, lastName);
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
      print('result.data.isNotEmpty ${result.data.isNotEmpty}');
      if (result.data.isNotEmpty) {
        students = List<Student>.from(
          result.data.map((studentJson) => Student.fromJson(studentJson)),
        );
      }
      print('students.length ${students.length}');
      notifyListeners();
    } catch (e, stacktrace) {
      if (kDebugMode) {
        _logger.i('handleEventJsonStudent $e $stacktrace');
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
      // case "Day":
      //   filteredAttendanceList.sort((a, b) =>
      //       order *
      //       (a.subjectSchedule?.day.index as num)
      //           .compareTo(b.subjectSchedule?.day.index as num));
      //   break;
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
      // case "Remarks":
      //   filteredAttendanceList
      //       .sort((a, b) => order * a.remarks.index.compareTo(b.remarks.index));
      //   break;
    }

    notifyListeners();
  }

  String _searchQueryStudent = '';

  void searchStudents(String query) {
    _searchQueryStudent = query;
    notifyListeners();
  }

  List<Student> get filteredStudents {
    print("students");
    print(students);
    if (_searchQueryStudent.isEmpty) {
      print(true);
      return students;
    } else {
      print('else');
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

  handEventJsonAttendanceAll(CRUDReturn result) {
    if (allAttendanceList.isNotEmpty) allAttendanceList.clear();

    for (Map<String, dynamic> map in result.data) {
      allAttendanceList.add(Attendance.fromJson(map));
    }
    _logger.i('allAttendanceList $allAttendanceList');
    filteredAttendanceList = allAttendanceList;
    attendanceListToDownload = allAttendanceList;
    notifyListeners();
  }

  void _handleEventJsonSchedule(CRUDReturn result) {
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

  List<Faculty> tempFac = [];
  void handleEventJsonFaculty(CRUDReturn result) {
    try {
      if (filteredFaculties.isNotEmpty) filteredFaculties.clear();

      if (result.data.isNotEmpty) {
        for (Map<String, dynamic> map in result.data) {
          filteredFaculties.add(Faculty.fromJson(map));
        }
      }
      tempFac = filteredFaculties;
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
      filteredFaculties = tempFac;
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
        attendance.remarks?.index,
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

  List<SubjectSchedule> tempFacultyClasses = [];
  void handleEventJsonFacultyClassesInput(CRUDReturn result) {
    try {
      if (tempFacultyClasses.isNotEmpty) tempFacultyClasses.clear();
      for (Map<String, dynamic> map in result.data) {
        tempFacultyClasses.add(SubjectSchedule.fromJson(map));
      }

      notifyListeners();
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print('handleEventJsonFacultyClassesInput $e $stacktrace');
      }
    }
  }

  Future<CRUDReturn> addFacultySubject(int facultyNo, int subjectId) async {
    try {
      CRUDReturn response =
          await FacultyService.addFacultySubject(facultyNo, subjectId);

      if (response.success) {
        notifyListeners();
        await getFacultyClassesTemp(facultyNo);
        return response;
      }
      notifyListeners();
      return response;
    } catch (e, stacktrace) {
      _logger.i('adminController addFacultySubject $e $stacktrace');
      CRUDReturn response = CRUDReturn(success: false, data: '$e');
      return response;
    }
  }

  Future<void> getFacultyClassesTemp(int facultyNo) async {
    try {
      // if (isStudentClassesCollected) return;
      isGettingClasses = true;
      notifyListeners();
      CRUDReturn response = await FacultyService.getFacultyClasses(facultyNo);
      if (response.success) {
        handleEventJsonFacultyClassesInput(response);
      }
      notifyListeners();
    } catch (e, stacktrace) {
      print('getFacultyClassesTemp $e $stacktrace');
    } finally {
      isGettingClasses = false;
      notifyListeners();
    }
  }

  Future<void> downloadClassListSchedId(
      context, int schedId, String subjectName, int subjectId) async {
    if (studentsTemp.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('No attendance data found'),
            content: const Text('There is no attendance data to download.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
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
        "Student No",
        "Name",
        "Year",
        "Course",
      ],
    ];

    for (Student student in studentsTemp) {
      List<dynamic> row = [
        student.studentNo,
        '${student.firstName} ${student.lastName}',
        student.year.name,
        student.course,
      ];
      csvData.add(row);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    String fileName = "${subjectId}_${subjectName}_Class_List.csv";
    if (kIsWeb) {
      // Web implementation
      AnchorElement(href: "data:text/csv;charset=utf-8,$csv")
        ..setAttribute("download", fileName)
        ..click();
    } else {
// Mobile implementation
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = io.File('$path/fileName');
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV file saved to: ${file.path}')),
      );
    }
  }

  void handleEventJsonStudentList(CRUDReturn result) {
    try {
      if (studentsTemp.isNotEmpty) studentsTemp.clear();
      Subject subjectStudent = Subject.fromJson(result.data[0]);
      if (subjectStudent.students == null) {
        return;
      }

      for (Student student in subjectStudent.students!) {
        print(student);
        studentsTemp.add(student);
      }

      notifyListeners();
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print('handleEventJsonStudentList $e $stacktrace');
      }
    }
  }

  bool isGetStudentListByLoading = false;
  Future<void> getStudentListbySchedId(int schedId) async {
    try {
      isGetStudentListByLoading = true;
      notifyListeners();

      CRUDReturn response = await StudentService.getStudentsBySchedId(schedId);
      if (kDebugMode) {
        _logger.i(' getStudentListbySchedId ${response.data}');
      }

      if (response.success) {
        if (kDebugMode) {
          _logger.i(' response.success');
        }
        handleEventJsonStudentList(response);
      }
      isGetStudentListByLoading = false;
      notifyListeners();
    } catch (e, stacktrace) {
      print('StudentListController getStudentListbySchedId $e $stacktrace');
    }
  }

  Future<void> getStudentClassesTemp() async {
    try {
      isGettingClasses = true;
      notifyListeners();
      CRUDReturn response =
          await StudentService.getStudentClasses(selectedStudent!.studentNo);
      if (response.success) {
        handleEventJsonStudentClasses(response);
      }
      notifyListeners();
    } catch (e, stacktrace) {
      print('StudentDashboardController getStudentClasses $e $stacktrace');
    } finally {
      isGettingClasses = false;
      notifyListeners();
    }
  }

  void handleEventJsonStudentClasses(CRUDReturn result) {
    try {
      if (studentClasses.isNotEmpty) studentClasses.clear();
      for (Map<String, dynamic> map in result.data) {
        studentClasses.add(SubjectSchedule.fromJson(map));
      }

      notifyListeners();
    } catch (e, stacktrace) {
      print('handleEventJsonStudentClasses $e $stacktrace');
    }
  }
}
