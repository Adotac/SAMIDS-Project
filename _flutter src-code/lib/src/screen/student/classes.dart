import 'package:flutter/material.dart';

import '../../controllers/student_controller.dart';
import '../../model/Subject_model.dart';
import '../../model/subjectSchedule_model.dart';
import '../../widgets/classes_tile_list.dart';
import '../../widgets/mobile_view.dart';
import '../page_size_constriant.dart';

class StudentClasses extends StatefulWidget {
  final StudentController sdController;
  static const routeName = '/student-classes';
  StudentClasses({Key? key, required this.sdController}) : super(key: key);

  @override
  State<StudentClasses> createState() => _StudentClassesState();
}

class _StudentClassesState extends State<StudentClasses> {
  StudentController get _sdController => widget.sdController;

  @override
  void initState() {
    super.initState();
    _sdController.getStudentClasses();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sdController,
      builder: (BuildContext context, Widget? child) {
        return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
          if (constraints.maxWidth <= 450) {
            return MobileView(
                appBarOnly: true,
                currentIndex: 2,
                appBarTitle: "My Classes",
                userName: "",
                body: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 2),
                    child: _buildClasses(context),
                  ),
                ]);
          } else {
            return const ScreenSizeWarning();
          }
        });
      },
    );
  }

  // bool _isSubjectToday(Subject subject) {
  //   final DateTime now = DateTime.now();
  //   final int today = now.weekday;
  //   final String daySchedule = subject.daySchedule.toUpperCase();

  //   if (today == DateTime.monday && daySchedule.contains('M')) {
  //     return true;
  //   } else if (today == DateTime.tuesday && daySchedule.contains('T')) {
  //     return true;
  //   } else if (today == DateTime.wednesday && daySchedule.contains('W')) {
  //     return true;
  //   } else if (today == DateTime.thursday && daySchedule.contains('H')) {
  //     return true;
  //   } else if (today == DateTime.friday && daySchedule.contains('F')) {
  //     return true;
  //   } else if (today == DateTime.saturday && daySchedule.contains('S')) {
  //     return true;
  //   }
  //   return false;
  // }

  Widget _buildClasses(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sdController.studentClasses.length,
      itemBuilder: (BuildContext context, int index) {
        SubjectSchedule schedule = _sdController.studentClasses[index];
        print(index);
        print(schedule.schedId);
        return ClassesListTile(
          subjectSchedule: schedule,
          subject: schedule.subject,
          onTap: () => showSubjectDetails(context, schedule, schedule.subject),
          enableShadow: false,
        );
      },
    );
  }

  void showSubjectDetails(
      BuildContext context, SubjectSchedule subjectSchedule, Subject? subject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            subject?.subjectName ?? '',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Code: ${subject?.subjectID}'),
                Text('Subject Description: ${subject?.subjectDescription}'),
                Text('Schedule Time: ${getTimeStartEnd(subjectSchedule)}'),
                // Text('Schedule Day: ${subjectSchedule.day.name}'),
                Text('Subject Teacher: ${getFaculty(subject!)}'),
                Text('Subject Room: ${subjectSchedule.room}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String getFaculty(Subject subject) {
    try {
      if (subject.faculties == null) {
        return 'No Faculty';
      }

      return '${subject.faculties?[0].firstName} ${subject.faculties?[0].lastName}';
    } catch (e) {
      return 'No Faculty';
    }
  }

  String getTimeStartEnd(SubjectSchedule subjectSchedule) {
    final timeStart = _sdController.formatTime(subjectSchedule.timeStart);
    final timeEnd = _sdController.formatTime(subjectSchedule.timeEnd);
    return '$timeStart - $timeEnd';
  }
}
