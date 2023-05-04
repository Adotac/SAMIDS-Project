import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';

import '../../controllers/student_controller.dart';
import '../../model/Subject_model.dart';
import '../../model/attendance_model.dart';
import '../../model/student_model.dart';
import '../../model/subjectSchedule_model.dart';
import '../../widgets/classes_tile_list.dart';
import '../../widgets/mobile_view.dart';
import '../page_size_constriant.dart';

class FacultySubjectClassList extends StatefulWidget {
  final FacultyController dataController;
  final String title;
  final String subjectId;
  final int schedId;
  static const routeName = '/faculty-classes-list';
  const FacultySubjectClassList(
      {Key? key,
      required this.dataController,
      required this.title,
      required this.schedId,
      required this.subjectId})
      : super(key: key);

  @override
  State<FacultySubjectClassList> createState() =>
      _FacultySubjectClassListState();
}

class _FacultySubjectClassListState extends State<FacultySubjectClassList> {
  FacultyController get _dataController => widget.dataController;
  int get schedId => widget.schedId;
  String get subjectId => widget.subjectId;
  String get title => widget.title;

  @override
  void initState() {
    _dataController.getStudentListbySchedId(schedId);
    super.initState();
    // _dataController.getFacultyClasses();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dataController,
      builder: (BuildContext context, Widget? child) {
        return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
          if (constraints.maxWidth < 360 || constraints.maxHeight < 650) {
            return const ScreenSizeWarning();
          }
          if (constraints.maxWidth <= 450 && constraints.maxWidth < 1578) {
            return Scaffold(
              appBar: AppBar(
                title: Text('$subjectId - $title'),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildClassList(context),
              ),
            );
          } else {
            return const ScreenSizeWarning();
          }
        });
      },
    );
  }

  Widget _buildClassList(BuildContext context) {
    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _dataController.students.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Class list',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                  ),
                  TextButton(
                      onPressed: () async {
                        await _dataController.downloadClassListSchedId(
                            context, schedId, title, int.parse(subjectId));
                      },
                      child: const Text("Download List")),
                ],
              ),
            );
          }
          Student student = _dataController.students[index - 1];
          return _classList(student);
        },
      ),
    );
  }

  Widget _classList(Student student) {
    if (_dataController.isGetStudentListByLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student No. ${student.studentNo}',
                  ),
                  Text(
                    '${student.firstName}  ${student.lastName}',
                  ),
                  // Text(
                  //   'Last Name: ${student.lastName}',
                  // ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${student.course} ${student.year.index +1}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                    // SizedBox(
                    //   width: 150,
                    //   child: Text(
                    //     'Course: ',
                    //     maxLines: 2,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: TextStyle(
                    //       fontSize: 14,
                    //       color: Theme.of(context).textTheme.bodySmall?.color,
                    //     ),
                    //   ),
                    // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getTimeStartEnd(SubjectSchedule subjectSchedule) {
    final timeStart = _dataController.formatTime(subjectSchedule.timeStart);
    final timeEnd = _dataController.formatTime(subjectSchedule.timeEnd);
    return '$timeStart - $timeEnd';
  }
}
