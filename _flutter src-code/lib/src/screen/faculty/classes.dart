import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';

import '../../controllers/student_controller.dart';
import '../../model/Subject_model.dart';
import '../../model/subjectSchedule_model.dart';
import '../../widgets/classes_tile_list.dart';
import '../../widgets/mobile_view.dart';

class FacultyClasses extends StatefulWidget {
  final FacultyController dataController;
  static const routeName = '/faculty-classes';
  FacultyClasses({Key? key, required this.dataController}) : super(key: key);

  @override
  State<FacultyClasses> createState() => _FacultyClassesState();
}

class _FacultyClassesState extends State<FacultyClasses> {
  FacultyController get _dataController => widget.dataController;

  @override
  void initState() {
    super.initState();
    _dataController.getFacultyClasses();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dataController,
      builder: (BuildContext context, Widget? child) {
        return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
          if (constraints.maxWidth <= 450) {
            return MobileView(
                appBarOnly: true,
                currentIndex: 2,
                appBarTitle: "Classes",
                userName: "",
                body: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 2),
                    child: _buildClasses(context),
                  ),
                ]);
          } else {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Classes"),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                    child: Text(
                      '1st Semester 2023',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                    child: Text(
                      'Total Units: 18',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    // _buildClasses(context),
                  ),
                ],
              ),
            );
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
      itemCount: _dataController.studentClasses.length,
      itemBuilder: (BuildContext context, int index) {
        SubjectSchedule schedule = _dataController.studentClasses[index];
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
                Text('Schedule Day: ${subjectSchedule.day.name}'),
                Text(
                    'Subject Teacher: ${subject?.faculties?[0].firstName} ${subject?.faculties?[0].lastName}'),
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

  String getTimeStartEnd(SubjectSchedule subjectSchedule) {
    final timeStart = _dataController.formatTime(subjectSchedule.timeStart);
    final timeEnd = _dataController.formatTime(subjectSchedule.timeEnd);
    return '$timeStart - $timeEnd';
  }
}
