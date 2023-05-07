import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samids_web_app/src/controllers/admin_controller.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';
import 'package:samids_web_app/src/model/subjectSchedule_model.dart';

import '../../model/subject_model.dart';

class SubjectDataSource extends DataTableSource {
  final List<SubjectSchedule> subjectSchedule;
  final AdminController _dataController;
  final BuildContext context;

  SubjectDataSource(this.subjectSchedule, this._dataController, this.context);
  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => subjectSchedule.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= subjectSchedule.length) return const DataRow(cells: []);
    final SubjectSchedule schedule = subjectSchedule[index];
    return _buildSubjectRow(context, schedule);
  }

  DataRow _buildSubjectRow(BuildContext context, SubjectSchedule schedule) {
    return DataRow(
      cells: [
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                schedule.schedId.toString(),
              ),
            ),
          ),
        ),
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                schedule.subject?.subjectName ?? 'No subject name',
              ),
            ),
          ),
        ),
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              schedule.subject?.subjectDescription ?? 'No subject description',
            ),
          ),
        ),
        DataCell(
          SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: Text(schedule.room)),
        ),
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(formatTime(schedule.timeStart)),
          ),
        ),
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(formatTime(schedule.timeEnd)),
          ),
        ),
        DataCell(
          SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: Text(schedule.day)),
        ),
        DataCell(
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        showEditSubjectScheduleDialog(context);
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.info_outline,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                      ))
                ],
              )),
        ),
        // DataCell(
        //   SingleChildScrollView(
        //       scrollDirection: Axis.horizontal,
        //       child: Text('${schedule.subject?.students?.length ?? '0'}')),
        // ),
      ],
    );
  }

  String formatTime(DateTime dateTime) {
    final formattedTime = DateFormat('hh:mm a').format(dateTime);
    return formattedTime;
  }

  Future<void> _showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => true,
          child: AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Sending...'),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showEditSubjectScheduleDialog(BuildContext context) async {
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime =
        TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 1)));

    Future<void> _pickTime(BuildContext context, TimeOfDay initialTime,
        Function(TimeOfDay) onPicked) async {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null) {
        onPicked(pickedTime);
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Subject Schedule'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Start Time'),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      await _pickTime(context, startTime, (newStartTime) {
                        setState(() {
                          startTime = newStartTime;
                        });
                      });
                    },
                    child: Text(
                      '${startTime.format(context)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('End Time'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      await _pickTime(context, endTime, (newEndTime) {
                        setState(() {
                          endTime = newEndTime;
                        });
                      });
                    },
                    child: Text(
                      '${endTime.format(context)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    // Save your changes here
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
