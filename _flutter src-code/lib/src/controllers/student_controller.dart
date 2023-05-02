import 'dart:convert';
import 'dart:html';
import 'dart:io' as io;

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:samids_web_app/src/model/attendance_model.dart';
import 'package:samids_web_app/src/model/student_model.dart';
import 'package:samids_web_app/src/model/subjectSchedule_model.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/attendance.services.dart';
import '../model/config_model.dart';
import '../services/config.services.dart';
import '../services/student.services.dart';

class StudentController with ChangeNotifier {
  final Student student;
  List<Attendance> attendance = [];
  List<Attendance> allAttendanceList = [];
  List<SubjectSchedule> studentClasses = [];
  List<Attendance> filteredAttendanceList = [];
  DateTime? dateSelected;

  double onTimeCount = 0;
  double lateCount = 0;
  double absentCount = 0;
  double cuttingCount = 0;
  bool sortAscending = true;

  String sortColumn = "";
  String searchQueryAttendance = "";

  bool isStudentClassesCollected = false;
  bool isCountCalculated = false;
  bool isAttendanceTodayCollected = false;
  bool isAllAttendanceCollected = false;

  Config? config;
  StudentController({required this.student});

  static void initialize(Student student) {
    GetIt.instance.registerSingleton<StudentController>(
        StudentController(student: student));
  }

  static StudentController get I => GetIt.instance<StudentController>();
  static StudentController get instance => GetIt.instance<StudentController>();

  logout() {
    isStudentClassesCollected = false;
    isCountCalculated = false;
    isAttendanceTodayCollected = false;
    isAllAttendanceCollected = false;

    onTimeCount = 0;
    lateCount = 0;
    absentCount = 0;
    cuttingCount = 0;

    attendance.clear();
    allAttendanceList.clear();
    studentClasses.clear();
  }

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

  handEventJsonAttendance(CRUDReturn result) {
    if (attendance.isNotEmpty) attendance.clear();
    for (Map<String, dynamic> map in result.data) {
      attendance.add(Attendance.fromJson(map));
    }

    isAttendanceTodayCollected = true;
    notifyListeners();
  }

  handEventJsonAttendanceAll(CRUDReturn result) {
    print('handEventJsonAttendanceAll');
    if (allAttendanceList.isNotEmpty) allAttendanceList.clear();

    for (Map<String, dynamic> map in result.data) {
      allAttendanceList.add(Attendance.fromJson(map));
    }
    filteredAttendanceList = allAttendanceList;
    print(filteredAttendanceList);
    notifyListeners();
  }

  void sortAttendance(String column) {
    sortAscending = sortColumn == column ? !sortAscending : true;
    sortColumn = column;

    int order = sortAscending ? 1 : -1;

    switch (column) {
      case "Reference No":
        filteredAttendanceList
            .sort((a, b) => order * (a.attendanceId.compareTo(b.attendanceId)));
        break;
      case "Name":
        filteredAttendanceList.sort((a, b) {
          int compare = a.subjectSchedule?.subject?.subjectName
                  .compareTo(b.subjectSchedule?.subject?.subjectName ?? '') ??
              0;
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
      case "Remarks":
        filteredAttendanceList
            .sort((a, b) => order * a.remarks.index.compareTo(b.remarks.index));
        break;
    }
    notifyListeners();
  }

  void searchAttendance(String query) {
    searchQueryAttendance = query;
    notifyListeners();
  }

  void filterAttendance(String query) {
    if (query.isEmpty) {
      filteredAttendanceList = allAttendanceList;
    } else {
      filteredAttendanceList = allAttendanceList.where((attendance) {
        final referenceNo = attendance.attendanceId.toString();
        // final day = attendance.subjectSchedule?.day.index.toString() == query;

        final subjectName =
            attendance.subjectSchedule?.subject?.subjectName.toLowerCase() ??
                '';

        final room = attendance.subjectSchedule?.room.toLowerCase() ?? '';
        final remarks = attendance.remarks.name.toLowerCase();
        return referenceNo.toString() == query ||
            subjectName.contains(query.toLowerCase()) ||
            room.contains(query.toLowerCase()) ||
            remarks.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> getAttendanceToday() async {
    try {
      if (isAttendanceTodayCollected) return;

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);

      CRUDReturn response = await AttendanceService.getAll(
          studentNo: student.studentNo, date: formattedDate);
      if (response.success) {
        handEventJsonAttendance(response);
        notifyListeners();
      }
    } catch (e, stacktrace) {
      print('StudentDashboardController getAttendanceNow $e $stacktrace');
    }
  }

  List<int> ex = [];
  Future<void> getStudentClasses() async {
    try {
      if (isStudentClassesCollected) return;
      CRUDReturn response =
          await StudentService.getStudentClasses(student.studentNo);
      if (response.success) {
        handleEventJsonStudentClasses(response);
        print(studentClasses);
      }
      notifyListeners();
    } catch (e, stacktrace) {
      print('StudentDashboardController getStudentClasses $e $stacktrace');
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

  Future<void> getAttendanceAll(String? date) async {
    try {
      if (isAllAttendanceCollected && date == null) return;
      print(['getAttendanceAll', date ?? 'No date', date != null]);
      CRUDReturn response = date != null
          ? await AttendanceService.getAll(
              studentNo: student.studentNo,
              date: date,
            )
          : await AttendanceService.getAll(
              studentNo: student.studentNo,
            );

      if (response.success) {
        await handEventJsonAttendanceAll(response);
        getRemarksCount();
        notifyListeners();
      }
      isAllAttendanceCollected = true;
    } catch (e, stacktrace) {
      isAllAttendanceCollected = true;
      print('StudentDashboardController getAttendanceAll $e $stacktrace');
    }
  }

  Future<void> attendanceReset() async {
    try {
      CRUDReturn response = await AttendanceService.getAll(
        studentNo: student.studentNo,
      );
      if (response.success) {
        await handEventJsonAttendanceAll(response);
        getRemarksCount();

        dateSelected = null;
        notifyListeners();
      }
      isAllAttendanceCollected = true;
    } catch (e, stacktrace) {
      print('StudentDashboardController getAttendanceAll $e $stacktrace');
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

  void getRemarksCount() {
    try {
      if (isCountCalculated) return;
      for (Attendance attendance in allAttendanceList) {
        if (attendance.remarks == Remarks.late) lateCount += 1;
        if (attendance.remarks == Remarks.onTime) onTimeCount += 1;
        if (attendance.remarks == Remarks.absent) absentCount += 1;
        if (attendance.remarks == Remarks.cutting) cuttingCount += 1;
        isCountCalculated = true;
        notifyListeners();
      }
      isCountCalculated = true;
    } catch (e, stacktrace) {
      isCountCalculated = true;
      print('getRemarksCount $e $stacktrace');
    }
  }

  Future<void> downloadData(context) async {
    if (filteredAttendanceList.isEmpty) {
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
        "Reference No",
        "Subject",
        "Date",
        "Day",
        "Room",
        "Time in",
        "Time out",
        "Remarks"
      ],
    ];

    for (Attendance attendance in filteredAttendanceList) {
      List<dynamic> row = [
        attendance.attendanceId,
        attendance.subjectSchedule?.subject?.subjectName ?? '',
        attendance.date?.toIso8601String() ?? '',
        attendance.subjectSchedule?.day?.toString() ?? '',
        attendance.subjectSchedule?.room ?? '',
        attendance.actualTimeIn?.hour.toString() ?? '',
        attendance.actualTimeOut?.hour.toString() ?? '',
        attendance.remarks.index,
      ];
      csvData.add(row);
    }

    String csv = const ListToCsvConverter().convert(csvData);

    if (kIsWeb) {
      // Web implementation
      AnchorElement(href: "data:text/csv;charset=utf-8,$csv")
        ..setAttribute("download", "attendance_data.csv")
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
}
