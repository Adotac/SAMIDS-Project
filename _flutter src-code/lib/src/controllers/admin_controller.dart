//faculty
//75779

import 'dart:convert';
import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'package:samids_web_app/src/model/attendance_model.dart';

import 'package:samids_web_app/src/model/subjectSchedule_model.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/attendance.services.dart';
import '../model/config_model.dart';
import '../model/faculty_model.dart';
import '../model/student_model.dart';
import '../services/config.services.dart';
import '../services/faculty.services.dart';
import '../services/student.services.dart';

class AdminController with ChangeNotifier {
  List<Attendance> attendance = [];
  List<Attendance> allAttendanceList = [];
  List<SubjectSchedule> studentClasses = [];
  List<Attendance> filteredAttendanceList = [];
  List<Student> students = [];
  String selectedUserType = 'Student';
  List<Faculty> filteredFaculties = [];

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

  static AdminController get I => GetIt.instance<AdminController>();
  static AdminController get instance => GetIt.instance<AdminController>();
  static void initialize() {
    GetIt.instance.registerSingleton<AdminController>(AdminController());
  }

  void setSelectedUserType(String userType) {
    selectedUserType = userType;
    notifyListeners();
  }

  void filterAttendance(String query) {
    if (query.isEmpty) {
      filteredAttendanceList = allAttendanceList;
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

  Future<void> getConfig() async {
    try {
      CRUDReturn response = await ConfigService.getConfig();
      if (response.success) {
        handleEventJsonConfig(response);
      }
    } catch (e, stacktrace) {
      print('ConfigController getConfig $e $stacktrace');
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
    notifyListeners();
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
      _logger.i('StudentDashboardController getAttendanceAll $e $stacktrace');
    }
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
}
