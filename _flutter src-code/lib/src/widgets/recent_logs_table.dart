import 'package:flutter/material.dart';

import '../controllers/data_controller.dart';
import '../model/attendance_model.dart'; // Import your controller

class ActivityLogsTable extends StatelessWidget {
  final DataController _sdController;

  const ActivityLogsTable({super.key, required DataController sdController})
      : _sdController = sdController;
  DateTime _getActualTime(Attendance attendance) =>
      attendance.actualTimeOut != null
          ? attendance.actualTimeOut!
          : attendance.actualTimeIn != null
              ? attendance.actualTimeIn!
              : DateTime.now();

  IconData _getStatusIcon(Remarks remarks) {
    switch (remarks) {
      case Remarks.onTime:
        return Icons.timer_outlined;
      case Remarks.late:
        return Icons.schedule_outlined;
      case Remarks.cutting:
        return Icons.cancel_outlined;
      case Remarks.absent:
        return Icons.highlight_off_outlined;
    }
  }

  DataRow _buildDataRow(BuildContext context, Attendance attendance) {
    return DataRow(
      cells: [
        DataCell(
          Text(_sdController.formatTime(_getActualTime(attendance)),
              style: TextStyle(fontSize: 14)),
        ),
        DataCell(
          Text(
            attendance.subjectSchedule?.subject?.subjectName ??
                'No subject name',
            style: TextStyle(fontSize: 14),
          ),
        ),
        DataCell(
          Row(
            children: [
              Icon(
                _getStatusIcon(attendance.remarks),
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                _sdController.getStatusText(attendance.remarks.name).toString(),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text(
                'Time',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Subject',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: _sdController.attendance
              .map((attendance) => _buildDataRow(context, attendance))
              .toList(),
        ),
      ),
    );
  }
}
