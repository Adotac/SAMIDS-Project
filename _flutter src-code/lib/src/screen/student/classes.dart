import 'package:flutter/material.dart';

import '../../model/test_subject.model.dart';
import '../../widgets/classes_tile_list.dart';
import '../../widgets/mobile_view.dart';

class StudentClasses extends StatelessWidget {
  static const routeName = '/student-classes';
  StudentClasses({Key? key}) : super(key: key);
  final List<Subject> subjects = [
    Subject(
      name: 'Computer Programming',
      code: 'CP101',
      timeSchedule: '1:30pm - 2:30pm',
      daySchedule: 'TTH',
      desc: 'Introduction to programming',
      teacher: 'John Doe',
      room: '101',
    ),
    Subject(
      name: 'Computer Programming',
      code: 'CP101',
      timeSchedule: '1:30pm - 2:30pm',
      daySchedule: 'MWF',
      desc: 'Introduction to programming',
      teacher: 'John Doe',
      room: '101',
    ),
    Subject(
      name: 'Computer Programming',
      code: 'CP101',
      timeSchedule: '1:30pm - 2:30pm',
      daySchedule: 'TTH',
      desc: 'Introduction to programming',
      teacher: 'John Doe',
      room: '101',
    ),
    Subject(
      name: 'Computer Programming',
      code: 'CP101',
      timeSchedule: '1:30pm - 2:30pm',
      daySchedule: 'S',
      desc: 'Introduction to programming',
      teacher: 'John Doe',
      room: '101',
    ),
    Subject(
      name: 'Computer Programming',
      code: 'CP101',
      timeSchedule: '1:30pm - 2:30pm',
      daySchedule: 'MWF',
      desc: 'Introduction to programming',
      teacher: 'John Doe',
      room: '101',
    ),
    Subject(
      name: 'Computer Programming',
      code: 'CP101',
      timeSchedule: '1:30pm - 2:30pm',
      daySchedule: 'F',
      desc: 'Introduction to programming',
      teacher: 'John Doe',
      room: '101',
    ),
    Subject(
      name: 'Computer Programming',
      code: 'CP101',
      timeSchedule: '1:30pm - 2:30pm',
      daySchedule: 'TTH',
      desc: 'Introduction to programming',
      teacher: 'John Doe',
      room: '101',
    ),
    Subject(
      name: 'Computer Programming',
      code: 'CP101',
      timeSchedule: '1:30pm - 2:30pm',
      daySchedule: 'MW',
      desc: 'Introduction to programming',
      teacher: 'John Doe',
      room: '101',
    ),

    // Add more subjects here
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
      if (constraints.maxWidth <= 450) {
        return MobileView(
          currentIndex: 2,
          appBarTitle: "Classes",
          userName: "",
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2),
            child: _buildClasses(context),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Classes"),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                child: Text(
                  '1st Semester 2023',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                child: Text(
                  'Total Units: 18',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                //  _buildClasses(context),
              ),
            ],
          ),
        );
      }
    });
  }

  bool _isSubjectToday(Subject subject) {
    final DateTime now = DateTime.now();
    final int today = now.weekday;
    final String daySchedule = subject.daySchedule.toUpperCase();

    if (today == DateTime.monday && daySchedule.contains('M')) {
      return true;
    } else if (today == DateTime.tuesday && daySchedule.contains('T')) {
      return true;
    } else if (today == DateTime.wednesday && daySchedule.contains('W')) {
      return true;
    } else if (today == DateTime.thursday && daySchedule.contains('H')) {
      return true;
    } else if (today == DateTime.friday && daySchedule.contains('F')) {
      return true;
    } else if (today == DateTime.saturday && daySchedule.contains('S')) {
      return true;
    }
    return false;
  }

  Widget _buildClasses(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subjects.length,
      itemBuilder: (BuildContext context, int index) {
        return ClassesListTile(
          subject: subjects[index],
          onTap: () => showSubjectDetails(context, subjects[index]),
          enableShadow: _isSubjectToday(subjects[index]),
        );
      },
    );
  }

  void showSubjectDetails(BuildContext context, Subject subject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            subject.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Subject Code: ${subject.code}'),
                Text('Subject Description: ${subject.desc}'),
                Text('Schedule Time: ${subject.timeSchedule}'),
                Text('Schedule Day: ${subject.daySchedule}'),
                Text('Subject Teacher: ${subject.teacher}'),
                Text('Subject Room: ${subject.room}'),
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

  // Widget _buildClasses(BuildContext context) {
  //   return ListView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemCount: subjects.length,
  //     itemBuilder: (BuildContext context, int index) {
  //       return ClassesListTile(

  //         subject: subjects[index],
  //         onTap: () => showSubjectDetails(context, subjects[index]),
  //       );
  //     },
  //   );
  // }

  // Widget _buildClasses(BuildContext context) {
  //   return Expanded(
  //     child: ListView.builder(
  //       itemCount: subjects.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return ClassesListTile(
  //           subject: subjects[index],
  //           onTap: () => showSubjectDetails(context, subjects[index]),
  //         );
  //       },
  //     ),
  //   );
  // }
}
