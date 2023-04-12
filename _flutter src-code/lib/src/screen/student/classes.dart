import 'package:flutter/material.dart';

import '../../widgets/mobile_view.dart';

class StudentClasses extends StatelessWidget {
  static const routeName = '/student-classes';
  const StudentClasses({Key? key}) : super(key: key);

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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                  child: dataTableClasses(context)),
            ),
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
                child: dataTableClasses(context),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget dataTableClasses(context) {
    return SizedBox(
      child: DataTable(
        dividerThickness: 1,
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
              'Subject Code',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Days',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        rows: [for (int i = 0; i < 10; i++) classesSampleDataRow(context)],
      ),
    );
  }

  DataRow classesSampleDataRow(context) {
    return DataRow(cells: <DataCell>[
      DataCell(Text('08:00 AM - 10:00 AM')),
      DataCell(Text('Computer Programming')),
      DataCell(Text('CP101')),
      DataCell(Text('MWF')),
    ]);
  }
}
