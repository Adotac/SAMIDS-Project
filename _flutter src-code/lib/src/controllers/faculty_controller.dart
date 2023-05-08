//faculty
//75779

import 'dart:async';
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
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/attendance.services.dart';
import '../model/config_model.dart';
import '../model/faculty_model.dart';
import '../model/subject_model.dart';
import '../services/config.services.dart';
import '../services/faculty.services.dart';
import '../services/student.services.dart';

class FacultyController with ChangeNotifier {
  final Logger _logger = Logger();
  final Faculty faculty;
  final List<Student> students = [];
  List<Attendance> attendance = [];
  List<Attendance> allAttendanceList = [];
  List<Attendance> graphAttendanceList = [];
  List<SubjectSchedule> facultyClasses = [];
  Map<int, List<Attendance>> attendanceBySchedId = {};
  Map<int, Map<Remarks, int>> remarksBySchedId = {};
  DateTime? dateSelected;
  bool sortAscending = true;
  String sortColumn = "";

  double onTimeCount = 0;
  double lateCount = 0;
  double absentCount = 0;
  double cuttingCount = 0;

  bool isGetStudentListByLoading = false;
  bool isRemarksCountBySchedId = false;
  bool isStudentsCollected = false;
  bool isStudentClassesCollected = false;
  bool isCountCalculated = false;
  bool isAttendanceTodayCollected = false;
  bool isAllAttendanceCollected = false;
  bool isRemarksCountListLoading = true;

  List<Map<String, Map<Remarks, int>>> remarksCountList = [];
  int maxRemarksCount = 0;

  FacultyController({required this.faculty});

  List<Attendance> filteredAttendanceList = [];

  static void initialize(Faculty faculty) {
    GetIt.instance.registerSingleton<FacultyController>(
        FacultyController(faculty: faculty));
  }

  static FacultyController get I => GetIt.instance<FacultyController>();
  static FacultyController get instance => GetIt.instance<FacultyController>();
  Timer? timer;
  Config? config;
  void startStream(context) {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      print(timer.tick);
      getFacultyClasses();
    });
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

  // Future<void> getFacultyClasses() async {
  //   try {
  //     if (isStudentClassesCollected) return;
  //     CRUDReturn response =
  //         await StudentService.getStudentClasses(faculty.facultyNo);
  //     if (response.success) {
  //       handleEventJsonStudentClasses(response);
  //     }
  //     notifyListeners();
  //   } catch (e, stacktrace) {
  //     print('StudentDashboardController getStudentClasses $e $stacktrace');
  //   }
  // }
  // Future<void> attendanceReset() async {
  //   try {
  //     CRUDReturn response = await AttendanceService.getAll(
  //         // studentNo: faculty.facultyNo,
  //         // studentNo: 91204,
  //         );
  //     if (response.success) {
  //       await handEventJsonAttendanceAll(response);
  //       getRemarksCount();
  //       isAllAttendanceCollected = true;

  //       dateSelected = null;
  //       notifyListeners();
  //     }
  //   } catch (e, stacktrace) {
  //     print('attendanceReset $e $stacktrace');
  //   }
  // }

  // Future<void> getAttendanceBySchedId(int schedId) async {
  //   try {
  //     CRUDReturn response = await AttendanceService.getAll(
  //       schedId: schedId,
  //       // studentNo: faculty.facultyNo,
  //       // studentNo: 91204,
  //     );
  //     if (response.success) {
  //       handleEventJsonAttendanceBySchedId(response, schedId);

  //       dateSelected = null;
  //       notifyListeners();
  //     }
  //   } catch (e, stacktrace) {
  //     print('getAttendanceBySchedId getAttendanceAll $e $stacktrace');
  //   }
  // }

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
    facultyClasses.clear();
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

    notifyListeners();
  }

  void handleEventJsonAttendanceBySchedId(CRUDReturn result, int schedId) {
    try {
      print('handleEventJsonAttendanceBySchedId');
      attendanceBySchedId.putIfAbsent(schedId, () => []);

      for (Map<String, dynamic> map in result.data) {
        attendanceBySchedId[schedId]?.add(Attendance.fromJson(map));
      }

      notifyListeners();
    } catch (e, stacktrace) {
      print('handleEventJsonAttendanceBySchedId $e $stacktrace');
    }
  }

  // Future<void> getStudentClasses() async {
  //   try {
  //     if (isStudentClassesCollected) return;
  //     CRUDReturn response =
  //         await StudentService.getStudentClasses(faculty.facultyNo);
  //     if (response.success) {
  //       handleEventJsonStudentClasses(response);
  //     }
  //     notifyListeners();
  //   } catch (e, stacktrace) {
  //     print('StudentDashboardController getStudentClasses $e $stacktrace');
  //   }
  // }

  void handleEventJsonFacultyClasses(CRUDReturn result) {
    try {
      if (facultyClasses.isNotEmpty) facultyClasses.clear();
      for (Map<String, dynamic> map in result.data) {
        facultyClasses.add(SubjectSchedule.fromJson(map));
      }

      isStudentClassesCollected = true;
      notifyListeners();
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print('handleEventJsonStudentClasses $e $stacktrace');
      }
    }
  }

  void handleEventJsonStudentList(CRUDReturn result) {
    try {
      print('handleEventJsonStudentList');
      print(result.data[0]);
      print('result.data[]');

      if (students.isNotEmpty) students.clear();
      Subject subjectStudent = Subject.fromJson(result.data[0]);
      if (subjectStudent.students == null) {
        return;
      }

      for (Student student in subjectStudent.students!) {
        print(student);
        students.add(student);
      }

      isStudentsCollected = true;
      notifyListeners();
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print('handleEventJsonStudentList $e $stacktrace');
      }
    }
  }

  Future<void> getStudentListbySchedId(int schedId) async {
    try {
      isGetStudentListByLoading = true;
      notifyListeners();
      print(schedId);
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

  DateTime? nearestDate(String daysOfWeek) {
    List<String> days = daysOfWeek.split(', ');
    Map<String, int> dayMapping = {
      'Mon': DateTime.monday,
      'Tue': DateTime.tuesday,
      'Wed': DateTime.wednesday,
      'Thurs': DateTime.thursday,
      'Fri': DateTime.friday,
      'Sat': DateTime.saturday,
      'Sun': DateTime.sunday,
    };

    DateTime today = DateTime.now();
    DateTime? nearestDate;
    int minDifference = 7;

    for (String day in days) {
      int? dayNumber = dayMapping[day];

      if (dayNumber != null) {
        DateTime currentDay =
            today.subtract(Duration(days: (today.weekday - dayNumber) % 7));
        int dayDifference = (currentDay.isBefore(today) ? 7 : 0) +
            currentDay.difference(today).inDays;

        if (dayDifference < minDifference) {
          nearestDate = currentDay;
          minDifference = dayDifference;
        }
      }
    }

    return nearestDate;
  }

  Widget buildNearestDateRow(BuildContext context, String daysOfWeek) {
    DateTime? nearestDateObj = nearestDate(daysOfWeek);
    if (nearestDateObj == null) {
      return const Text('No valid days provided');
    }
    String monthName = DateFormat('MMMM').format(nearestDateObj);
    String day = DateFormat('d').format(nearestDateObj);
    String weekday = DateFormat('EEEE').format(nearestDateObj);

    return Row(
      children: [
        Text(
          '$monthName, $day, ${nearestDateObj.year}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(' - '),
        Text(
          weekday,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Future<void> getAttendanceBySchedId(int schedId, DateTime date) async {
    try {
      print([1, schedId]);
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      CRUDReturn response = await AttendanceService.getAttendances(
        schedId: schedId,
        //Remove me
        date: dateFormat.format(date),
        // studentNo: faculty.facultyNo,
        // studentNo: 91204,
      );
      if (response.success) {
        handleEventJsonAttendanceBySchedId(response, schedId);

        dateSelected = null;
        notifyListeners();
      }
    } catch (e, stacktrace) {
      print('getAttendanceBySchedId getAttendanceAll $e $stacktrace');
    }
  }

  //create function to query to FacultyService getFacultyClasses
  Future<void> getFacultyClasses() async {
    try {
      if (isStudentClassesCollected) return;
      CRUDReturn response =
          await FacultyService.getFacultyClasses(faculty.facultyNo);
      if (response.success) {
        handleEventJsonFacultyClasses(response);
        for (final element in facultyClasses) {
          DateTime date = nearestDate(element.day)!;
          await getAttendanceBySchedId(element.schedId, date);
        }
        getRemarksCountBySchedId();
      }
      notifyListeners();
    } catch (e, stacktrace) {
      print('StudentDashboardController getStudentClasses $e $stacktrace');
    }
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

  Future<void> getFacultyClassesTemp(int facultyNo) async {
    try {
      if (isStudentClassesCollected) return;
      CRUDReturn response = await FacultyService.getFacultyClasses(facultyNo);
      if (response.success) {
        handleEventJsonFacultyClassesInput(response);
      }
      notifyListeners();
    } catch (e, stacktrace) {
      print('getFacultyClassesTemp $e $stacktrace');
    }
  }

  Future<void> getAttendanceAll(String? date) async {
    try {
      // if (isAllAttendanceCollected && date == null) return;
      CRUDReturn response = date != null
          ? await AttendanceService.getAttendances(
              facultyNo: faculty.facultyNo,
              date: date,
            )
          : await AttendanceService.getAttendances(
              facultyNo: faculty.facultyNo,
            );

      if (response.success) {
        await handEventJsonAttendanceAll(response);

        if (graphAttendanceList.isEmpty) {
          // graphAttendanceList = allAttendanceList;
          print('graphAttendanceList');
        }
        getRemarksCount();
        getRemarksCountForPercentiles();
        isAllAttendanceCollected = true;
        filteredAttendanceList = allAttendanceList;
        notifyListeners();
      }
    } catch (e, stacktrace) {
      isAllAttendanceCollected = true;
      print('getAttendanceAll getAll $e $stacktrace');
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

  Color getStatusColor(Remarks? remarks, BuildContext context) {
    if (remarks == null) {
      return Theme.of(context).primaryColor;
    } else {
      switch (remarks) {
        case Remarks.pending:
          return Colors.grey;
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
      //       .sort((a, b) => order * a.remarks?.index.compareTo(b.remarks?.index));
      //   break;
    }
    notifyListeners();
  }

  Text getStatusText(String status) {
    final String lowercaseStatus = status.toLowerCase();
    Color color;
    String text = '';
    switch (lowercaseStatus) {
      case 'pending':
        color = Colors.grey;
        text = 'Pending';
        break;
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
    } catch (e, stacktrace) {
      isCountCalculated = true;
      print('getRemarksCount $e $stacktrace');
    }
  }

  void getRemarksCountBySchedId() {
    try {
      for (var entry in attendanceBySchedId.entries) {
        int schedId = entry.key;
        List<Attendance> attendanceList = entry.value;

        final remarksCount = <Remarks, int>{};
        for (var attendance in attendanceList) {
          if (attendance.remarks == null) continue;
          if (remarksCount.containsKey(attendance.remarks)) {
            remarksCount[attendance.remarks!] =
                remarksCount[attendance.remarks]! + 1;
          } else {
            remarksCount[attendance.remarks!] = 1;
          }
        }

        remarksBySchedId[schedId] = remarksCount;
      }

      isRemarksCountBySchedId = true;
      notifyListeners();
    } catch (e, stacktrace) {
      print('getRemarksCountBySchedId $e $stacktrace');
    }
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

        final referenceId = attendance.attendanceId.toString();
        final room = attendance.subjectSchedule?.room.toLowerCase() ?? '';
        final remarks = attendance.remarks?.name.toLowerCase() ?? 'Pending';
        return firstName.contains(query.toLowerCase()) ||
            referenceId.contains(query.toLowerCase()) ||
            studentNo.toString() == query ||
            lastName.contains(query.toLowerCase()) ||
            subjectName.contains(query.toLowerCase()) ||
            room.contains(query.toLowerCase()) ||
            remarks.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void getRemarksCountByClasses() {
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
    } catch (e, stacktrace) {
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

    for (Attendance attendance in filteredAttendanceList) {
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

  List<Attendance> tempAttendance = [];
  String btnName = 'Today';

  void filterTodayAttendance(schedId) {
    if (btnName == 'All') {
      btnName = 'Today';
    } else {
      btnName = 'All';
      attendanceBySchedId[schedId] = tempAttendance;
      notifyListeners();
      return;
    }
    notifyListeners();
    List<Attendance> todayAttendance = [];
    final now = DateTime.now();
    tempAttendance = attendanceBySchedId[schedId]!;
    final today = DateTime(now.year, now.month, now.day);
    todayAttendance = attendanceBySchedId[schedId]!
        .where((attendance) =>
            attendance.date != null && attendance.date!.isAtSameMomentAs(today))
        .toList();
    attendanceBySchedId[schedId] = todayAttendance;
    notifyListeners();
  }

  Future<void> downloadAttendanceBySchedId(
      context, int schedId, String subjectName, int subjectId) async {
    if (attendanceBySchedId[schedId]!.isEmpty) {
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
        "Reference ID",
        "Name",
        "Time In",
        "Time out",
        "Remarks",
      ],
    ];

    for (Attendance attendance in attendanceBySchedId[schedId]!) {
      List<dynamic> row = [
        attendance.attendanceId,
        '${attendance.student?.firstName ?? ''} ${attendance.student?.lastName ?? ''}',
        attendance.actualTimeIn?.toString() ?? '',
        attendance.actualTimeOut?.toString() ?? '',
        attendance.remarks?.name ?? 'Pending',
      ];
      csvData.add(row);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    String fileName = "${subjectId}_${subjectName}_Attendance_List.csv";
    if (kIsWeb) {
      // Web implementation
      AnchorElement(href: "data:text/csv;charset=utf-8,$csv")
        ..setAttribute("download", fileName)
        ..click();
    } else {
// Mobile implementation
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = io.File('$path/$fileName');
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV file saved to: ${file.path}')),
      );
    }
  }

  Future<void> downloadClassListSchedId(
      context, int schedId, String subjectName, int subjectId) async {
    if (students.isEmpty) {
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

    for (Student student in students) {
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

  // bool _isDateWithinPastSixDays(DateTime date) {
  //   DateTime now = DateTime.now();
  //   DateTime sixDaysAgo = now.subtract(Duration(days: 6));
  //   return date.isAfter(sixDaysAgo) && date.isBefore(now);
  // }

  // Map<Remarks, int> countMap = {
  //   Remarks.onTime: 0,
  //   Remarks.late: 0,
  //   Remarks.cutting: 0,
  //   Remarks.absent: 0,
  // };
  // void getRemarksCountAllAtt() {
  //   print('getRemarksCountAllAtt');
  //   for (Attendance attendance in allAttendanceList) {
  //     if (attendance.date != null &&
  //         _isDateWithinPastSixDays(attendance.date!)) {
  //       countMap[attendance.remarks] = countMap[attendance.remarks]! + 1;
  //     }
  //   }

  //   print(countMap);
  //   notifyListeners();
  // }

  // List<Remarks> getLastSixRecordedDaysRemarks() {
  //   print('getLastSixRecordedDaysRemarks');
  //   List<Remarks> lastSixDaysRemarks = [];

  //   // Create a map to group attendance by date
  //   Map<DateTime, List<Attendance>> attendanceByDate = {};
  //   for (Attendance attendance in allAttendanceList) {
  //     if (attendance.date != null) {
  //       DateTime date = DateTime.utc(attendance.date!.year,
  //           attendance.date!.month, attendance.date!.day);
  //       attendanceByDate[date] = attendanceByDate[date] ?? [];
  //       attendanceByDate[date]!.add(attendance);
  //     }
  //   }

  //   // Iterate through the map to get the last 6 recorded days
  //   List<DateTime> lastSixRecordedDays = [];
  //   DateTime today = DateTime.now().toUtc();
  //   for (int i = 0; i < 6; i++) {
  //     DateTime day = today.subtract(Duration(days: i));
  //     if (attendanceByDate.containsKey(day)) {
  //       lastSixRecordedDays.add(day);
  //     }
  //   }

  //   // Iterate through the attendance list and add the remarks for the last 6 recorded days
  //   for (Attendance attendance in allAttendanceList) {
  //     if (attendance.date != null) {
  //       DateTime date = DateTime.utc(attendance.date!.year,
  //           attendance.date!.month, attendance.date!.day);
  //       if (lastSixRecordedDays.contains(date)) {
  //         lastSixDaysRemarks.add(attendance.remarks);
  //       }
  //     }
  //   }

  //   print(lastSixDaysRemarks);
  //   print('lastSixDaysRemarks');
  //   return lastSixDaysRemarks;
  // }

  // List<Remarks> getLastSixDaysRemarks() {
  //   print('lastSixDaysRemarks');
  //   List<Remarks> lastSixDaysRemarks = [];

  //   // Sort the allAttendanceList in descending order based on the date
  //   allAttendanceList.sort((a, b) => b.date!.compareTo(a.date!));

  //   // Create a Set to store unique dates
  //   Set<DateTime> uniqueDates = {};

  //   for (Attendance attendance in allAttendanceList) {
  //     if (attendance.date != null) {
  //       // Remove the time part from the date to consider only the unique day
  //       DateTime dateOnly = DateTime(attendance.date!.year,
  //           attendance.date!.month, attendance.date!.day);

  //       // Check if the date is unique and the uniqueDates Set has less than 6 elements
  //       if (!uniqueDates.contains(dateOnly) && uniqueDates.length < 6) {
  //         lastSixDaysRemarks.add(attendance.remarks);
  //         uniqueDates.add(dateOnly);
  //       }
  //     }
  //   }
  //   print(lastSixDaysRemarks);
  //   print(uniqueDates);
  //   return lastSixDaysRemarks;
  // }

  // List<Map<DateTime, Map<Remarks, int>>> getRemarksCountForLastSixDays() {
  //   print('getRemarksCountForLastSixDays');
  //   List<Map<DateTime, Map<Remarks, int>>> remarksCountList = [];

  //   // Sort the allAttendanceList in descending order based on the date
  //   allAttendanceList.sort((a, b) => b.date!.compareTo(a.date!));

  //   // Create a Set to store unique dates
  //   Set<DateTime> uniqueDates = {};

  //   for (Attendance attendance in allAttendanceList) {
  //     if (attendance.date != null) {
  //       // Remove the time part from the date to consider only the unique day
  //       DateTime dateOnly = DateTime(attendance.date!.year,
  //           attendance.date!.month, attendance.date!.day);

  //       // Check if the date is unique and the uniqueDates Set has less than 6 elements
  //       if (!uniqueDates.contains(dateOnly) && uniqueDates.length < 6) {
  //         uniqueDates.add(dateOnly);
  //       }
  //     }
  //   }

  //   for (DateTime uniqueDate in uniqueDates) {
  //     Map<Remarks, int> remarksCount = {
  //       Remarks.onTime: 0,
  //       Remarks.late: 0,
  //       Remarks.cutting: 0,
  //       Remarks.absent: 0
  //     };

  //     for (Attendance attendance in allAttendanceList) {
  //       if (attendance.date != null) {
  //         DateTime dateOnly = DateTime(attendance.date!.year,
  //             attendance.date!.month, attendance.date!.day);

  //         if (uniqueDate == dateOnly) {
  //           remarksCount[attendance.remarks] =
  //               remarksCount[attendance.remarks]! + 1;
  //         }
  //       }
  //     }

  //     remarksCountList.add({uniqueDate: remarksCount});
  //   }
  //   print(remarksCountList);
  //   return remarksCountList;
  // }
  List<String> formattedDateRangeList = [];
  void getRemarksCountForPercentiles() {
    try {
      notifyListeners();
      print('getRemarksCountForPercentiles');
      print(['graphAttendanceList', 11]);
      graphAttendanceList.sort((a, b) => b.date!.compareTo(a.date!));

      Set<DateTime> uniqueDates = {};

      for (Attendance attendance in graphAttendanceList) {
        if (attendance.date != null) {
          DateTime dateOnly = DateTime(attendance.date!.year,
              attendance.date!.month, attendance.date!.day);

          uniqueDates.add(dateOnly);
        }
      }

      int divisor = 6;
      if (uniqueDates.length < 6) {
        divisor = uniqueDates.length;
        print(uniqueDates.length);
      }
      print(['graphAttendanceList', 10]);
      int datesPerPercentile = (uniqueDates.length / divisor).ceil();

      for (int i = 0; i < divisor; i++) {
        List<DateTime> percentileDates = uniqueDates
            .skip(i * datesPerPercentile)
            .take(datesPerPercentile)
            .toList();
        String percentileLabel = percentileDates.isEmpty
            ? 'Empty'
            : '${percentileDates.first} - ${percentileDates.last}';

        Map<Remarks, int> remarksCount = {
          Remarks.pending: 0,
          Remarks.onTime: 0,
          Remarks.late: 0,
          Remarks.cutting: 0,
          Remarks.absent: 0
        };
        print(['graphAttendanceList', 9]);
        for (Attendance attendance in graphAttendanceList) {
          if (attendance.date != null) {
            if (attendance.remarks == null) continue;
            DateTime dateOnly = DateTime(attendance.date!.year,
                attendance.date!.month, attendance.date!.day);

            if (percentileDates.contains(dateOnly)) {
              remarksCount[attendance.remarks!] =
                  remarksCount[attendance.remarks]! + 1;
            }
          }
        }

        remarksCountList.add({percentileLabel: remarksCount});
      }

      Remarks maxRemarks = Remarks.onTime;
      print(['graphAttendanceList', 8]);
      for (Map<String, Map<Remarks, int>> data in remarksCountList) {
        String dateRange = data.keys.first;
        Map<Remarks, int> remarksCount = data.values.first;

        // Iterate through the remarks count and update the max count if needed
        for (Remarks remark in remarksCount.keys) {
          int count = remarksCount[remark]!;
          if (count > maxRemarksCount) {
            maxRemarksCount = count;
            maxRemarks = remark;
          }
        }
        print(['graphAttendanceList', 7]);
        DateTime startDate = DateTime.parse(dateRange.split(' - ')[0]);
        DateTime endDate = DateTime.parse(dateRange.split(' - ')[1]);

        String formattedDateRange = DateFormat('MMMM').format(endDate);

        formattedDateRangeList.add(formattedDateRange);

        for (Remarks remark in remarksCount.keys) {
          print(['graphAttendanceList', 99]);
          int count = remarksCount[remark] ?? 0;
          print('$remark: $count');
          print(['graphAttendanceList', 100]);
        }
      }

      print('Max remarks count: $maxRemarksCount');
      print('Max remarks: $maxRemarks');

      final count = getPercentileCounts();
      print(count);
      isRemarksCountListLoading = false;
      notifyListeners();
    } catch (e, stacktrace) {
      print(['graphAttendanceList', stacktrace]);
      print(['graphAttendanceList', e]);
      isRemarksCountListLoading = false;
      notifyListeners();
    }
  }

  List<int> getPercentileCounts() {
    List<int> percentileCounts = [];

    int countPerPercentile = (maxRemarksCount / 5).ceil();

    for (int i = 1; i <= 5; i++) {
      int count = i * countPerPercentile;
      percentileCounts.add(count);
    }

    return percentileCounts;
  }

  List<double> getCountOfRemark(Remarks desiredRemark) {
    List<double> remarkCountList = [];
    for (Map<String, Map<Remarks, int>> data in remarksCountList) {
      Map<Remarks, int> remarksCount = data.values.first;
      int count = remarksCount[desiredRemark] ?? 0;
      remarkCountList.add(count.toDouble());
    }
    return remarkCountList;
  }
}
