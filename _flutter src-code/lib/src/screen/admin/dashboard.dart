import 'package:flutter/material.dart';

import '../../controllers/admin_controller.dart';
import '../../widgets/web_view.dart';

class AdminDashboard extends StatefulWidget {
  static const String routeName = '/admin-dashboard';
  final AdminController adminController;
  const AdminDashboard({super.key, required this.adminController});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  AdminController get adminController => widget.adminController;

  @override
  void initState() {
    super.initState();
  }

  bool isMobile(BoxConstraints constraints) {
    return (constraints.maxWidth <= 450);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
      if (isMobile(constraints)) {
        return _mobileView();
      }

      return _webView();
    });
  }

  Widget _webView() {
    return AnimatedBuilder(
      animation: adminController,
      builder: (context, child) {
        return WebView(
          appBarTitle: "Admin Dashboard",
          selectedWidgetMarker: 0,
          body: _webDashboardBody(),
        );
      },
    );
  }

  Widget _mobileView() {
    return AnimatedBuilder(
      animation: adminController,
      builder: (context, child) {
        return SizedBox();
      },
    );
  }

  Widget _webDashboardBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildConfig(context),
          ),
          const VerticalDivider(width: 32.0),
          Expanded(
            child: _buildUpload(),
          ),
          const VerticalDivider(width: 32.0),
          Expanded(
            child: Container(color: Colors.blue),
          ),
        ],
      ),
    );
  }

  _buildUpload() {
    return Text("data");
  }

  Widget _buildConfig(context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Config",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _termInfo(),
            const SizedBox(height: 16.0),
            _timeOffset(),
            const SizedBox(height: 16.0),
            _dataTableClasses(context)
          ],
        ),
      ),
    );
  }

  Card _termInfo() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Term Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Set Term'),
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _titleText("2023-2024")),
                    const Text('Current Year'),
                  ],
                ),
                const SizedBox(width: 24.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _titleText("2nd Semester")),
                    const Text('Current Term'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card _timeOffset() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Time Offset',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Set offset'),
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _titleText("25 mins")),
                    const Text('Minutes Late'),
                  ],
                ),
                const SizedBox(width: 24.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _titleText("30 minds")),
                    const Text('Minutes Absent'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleText(text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  List<Map<String, dynamic>> sampleStudentClasses = [
    {
      'subject': 'Data Structures and Algorithms',
      'room': 'BCL1',
      'timeStart': DateTime(2023, 4, 1, 5, 30),
      'timeEnd': DateTime(2023, 4, 1, 6, 30),
      'day': 'Mon, Wed, Fri',
    },
    {
      'subject': 'Operating Systems',
      'room': 'BCL2',
      'timeStart': DateTime(2023, 4, 1, 10, 0),
      'timeEnd': DateTime(2023, 4, 1, 11, 30),
      'day': 'Tue, Thu',
    },
    {
      'subject': 'Design and Analysis of Algorithms',
      'room': 'BCL3',
      'timeStart': DateTime(2023, 4, 1, 2, 0),
      'timeEnd': DateTime(2023, 4, 1, 3, 30),
      'day': 'Mon, Wed, Fri',
    },
    {
      'subject': 'Natural Language Processing',
      'room': 'BCL4',
      'timeStart': DateTime(2023, 4, 1, 13, 0),
      'timeEnd': DateTime(2023, 4, 1, 14, 30),
      'day': 'Tue, Thu',
    },
    {
      'subject': 'Programming Languages',
      'room': 'BCL5',
      'timeStart': DateTime(2023, 4, 1, 16, 0),
      'timeEnd': DateTime(2023, 4, 1, 17, 30),
      'day': 'Mon, Wed, Fri',
    },
    // {
    //   'subject': 'Calculus',
    //   'room': 'BCL6',
    //   'timeStart': DateTime(2023, 4, 1, 8, 0),
    //   'timeEnd': DateTime(2023, 4, 1, 9, 30),
    //   'day': 'Tue, Thu',
    // },
    {
      'subject': 'Machine Learning',
      'room': 'BCL7',
      'timeStart': DateTime(2023, 4, 1, 14, 30),
      'timeEnd': DateTime(2023, 4, 1, 16, 0),
      'day': 'Mon, Wed, Fri',
    },
    // {
    //   'subject': 'Apps Development 2',
    //   'room': 'BCL8',
    //   'timeStart': DateTime(2023, 4, 1, 9, 0),
    //   'timeEnd': DateTime(2023, 4, 1, 10, 30),
    //   'day': 'Tue, Thu',
    // },
    // {
    //   'subject': 'Software Engineering 2',
    //   'room': 'BCL9',
    //   'timeStart': DateTime(2023, 4, 1, 11, 0),
    //   'timeEnd': DateTime(2023, 4, 1, 12, 30),
    //   'day': 'Mon, Wed, Fri',
    // },
  ];

  Widget _dataTableClasses(context) {
    return Card(
      child: DataTable(columns: [
        customDataColumn(label: Text('Subject'), flex: 3),
        customDataColumn(label: Text('Time'), flex: 1),
      ], rows: _buildSampleDataRows(context)
          //create for loop to 5

          ),
    );
  }

  DataColumn customDataColumn({required Widget label, int flex = 1}) {
    return DataColumn(
      label: Expanded(
        flex: flex,
        child: label,
      ),
    );
  }

  List<DataRow> _buildSampleDataRows(BuildContext context) {
    return sampleStudentClasses.map((schedule) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              schedule['subject'],
              style: TextStyle(fontSize: 14),
            ),
          ),
          DataCell(
            Text(
              '${schedule['timeStart'].hour == 0 ? 12 : (schedule['timeStart'].hour < 13 ? schedule['timeStart'].hour : schedule['timeStart'].hour - 12).toString().padLeft(2, '0')}:${schedule['timeStart'].minute.toString().padLeft(2, '0')} ${schedule['timeStart'].hour < 12 ? 'AM' : 'PM'} - ${(schedule['timeEnd'].hour == 0 ? 12 : (schedule['timeEnd'].hour < 13 ? schedule['timeEnd'].hour : schedule['timeEnd'].hour - 12)).toString().padLeft(2, '0')}:${schedule['timeEnd'].minute.toString().padLeft(2, '0')} ${schedule['timeEnd'].hour < 12 ? 'AM' : 'PM'}',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
