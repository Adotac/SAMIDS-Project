import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/app_bar.dart';
import 'package:samids_web_app/src/widgets/card_small.dart';
import 'package:samids_web_app/src/widgets/mobile_view.dart';

import 'package:samids_web_app/src/widgets/title_medium_text.dart';

class StudentClasses extends StatelessWidget {
  static const routeName = '/student-classes';
  const StudentClasses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
      if (constraints.maxWidth <= 450) {
        return MobileView(
          appBarTitle: "Classes",
          userName: "",
          body: Column(
            children: [
              LocalAppBar(pageTitle: "Classes"),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleMediumText(title: "Classes"),
                    SizedBox(height: 16),
                    dataTableClasses(context),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return Scaffold(
          body: Column(
            children: [
              LocalAppBar(pageTitle: "Classes"),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleMediumText(title: "Classes"),
                    SizedBox(height: 16),
                    dataTableClasses(context),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget dataTableClasses(context) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        dividerThickness: 0,
        columnSpacing: 5,
        columns: [
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
        rows: [for (int i = 0; i < 10; i++) classesSampleDataRow(context)],
      ),
    );
  }

  DataRow classesSampleDataRow(context) {
    return DataRow(cells: <DataCell>[
      DataCell(Text('08:00 AM - 10:00 AM')),
      DataCell(Text('Computer Programming')),
      DataCell(Text('Pending')),
    ]);
  }
}
