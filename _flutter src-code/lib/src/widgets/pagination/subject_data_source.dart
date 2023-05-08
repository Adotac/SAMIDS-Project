import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samids_web_app/src/controllers/admin_controller.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';
import 'package:samids_web_app/src/model/subjectSchedule_model.dart';
import 'package:samids_web_app/src/services/config.services.dart';

import '../../model/student_model.dart';
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
                '${schedule.faculty?.firstName ?? 'No Faculty'} ${schedule.faculty?.lastName ?? ''} ',
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
            child: Container(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                maxLines: 2,
                schedule.subject?.subjectDescription ??
                    'No subject description',
              ),
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
                        showEditSubjectScheduleDialog(
                            context,
                            schedule.schedId,
                            schedule.subject?.subjectName ?? 'No Code',
                            schedule.timeStart,
                            schedule.timeEnd);
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                      )),
                  IconButton(
                      onPressed: () {
                        _dataController.getStudentListbySchedId(
                            schedule.subject?.subjectID ?? 0);
                        _showMyClassesDialog(
                          context,
                          schedule.schedId,
                          schedule.subject?.subjectName ?? 'No Subject',
                          schedule.schedId,
                        );
                      },
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

  Future<void> showEditSubjectScheduleDialog(BuildContext context, int schedId,
      String code, DateTime timeStart, DateTime timeEnd) async {
    TimeOfDay startTime = TimeOfDay.fromDateTime(timeStart);
    TimeOfDay endTime = TimeOfDay.fromDateTime(timeEnd);

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
              title: Row(
                children: [
                  const Text('Edit '),
                  Text(
                    code,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  const Text(' schedule'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 8),
                  const Text('Start Time'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      await _pickTime(context, startTime, (newStartTime) {
                        setState(() {
                          startTime = newStartTime;

                          if (startTime.hour > endTime.hour ||
                              (startTime.hour == endTime.hour &&
                                  startTime.minute > endTime.minute)) {
                            endTime = TimeOfDay(
                                hour: startTime.hour, minute: startTime.minute);
                          }
                        });
                      });
                    },
                    child: Text(
                      startTime.format(context),
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

                          if (endTime.hour < startTime.hour ||
                              (endTime.hour == startTime.hour &&
                                  endTime.minute < startTime.minute)) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Error',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  content: const Text(
                                      'End time cannot be earlier than start time.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        });
                      });
                    },
                    child: Text(
                      endTime.format(context),
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
                  onPressed: () async {
                    DateTime endTimeDate =
                        DateTime(2023, 1, 1, endTime.hour, endTime.minute);
                    String isoTimeEnd = endTimeDate.toIso8601String();

                    DateTime startTimeDate =
                        DateTime(2023, 1, 1, startTime.hour, startTime.minute);
                    String isoTimeStart = startTimeDate.toIso8601String();
                    await ConfigService.updateSubject(
                        isoTimeStart, isoTimeEnd, schedId);
                    await _dataController.getSubjectSchedules();

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

  void _showMyClassesDialog(
      BuildContext context, subjectId, title, int schedId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: _dataController,
          builder: (context, _) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$title - Class List'),
                  TextButton(
                      onPressed: () async {
                        await _dataController.downloadClassListSchedId(
                            context, schedId, title, subjectId);
                      },
                      child: Text("Download Table")),
                ],
              ),
              content: SingleChildScrollView(
                child: _dataTableClassList(context, schedId),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dataTableClassList(context, int schedId) {
    // if (_dataController.isGetStudentListByLoading) {
    //   return Center(child: CircularProgressIndicator());
    // }

    return DataTable(
      columns: [
        _customDataColumn(label: Text('Student No.'), flex: 3),
        _customDataColumn(label: Text('First Name'), flex: 1),
        _customDataColumn(label: Text('Last Name'), flex: 1),
        _customDataColumn(label: Text('Year'), flex: 1),
        _customDataColumn(label: Text('Course'), flex: 1),
      ],
      rows: _dataController.studentsTemp
          .map((student) => _buildDataRowClassList(context, student))
          .toList(),
    );
  }

  DataColumn _customDataColumn({required Widget label, int flex = 1}) {
    return DataColumn(
      label: Expanded(
        flex: flex,
        child: label,
      ),
    );
  }

  DataRow _buildDataRowClassList(BuildContext context, Student student) {
    return DataRow(
      cells: [
        _tableDataCell(student.studentNo.toString()),
        _tableDataCell(student.firstName),
        _tableDataCell(student.lastName),
        _tableDataCell(student.year.name),
        _tableDataCell(student.course),
      ],
    );
  }

  _tableDataCell(String text) {
    return DataCell(
      Text(
        text,
        style: TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }
}
