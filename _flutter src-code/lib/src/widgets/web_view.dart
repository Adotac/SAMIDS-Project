import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/model/attendance_model.dart';
import 'package:samids_web_app/src/model/attendance_search_params.dart';
import 'package:samids_web_app/src/widgets/attendance/attendance_filter_form.dart';
import 'package:samids_web_app/src/widgets/notification_tile_list.dart';
import 'package:samids_web_app/src/widgets/side_menu.dart';

import '../controllers/admin_controller.dart';
import '../controllers/auth.controller.dart';
import '../controllers/student_controller.dart';

enum FilterOptions { subjectId, date, time }

class WebView extends StatefulWidget {
  final String appBarTitle;
  final Widget body;
  final int selectedWidgetMarker;
  final bool showBackButton;
  final Widget? appBarActionWidget;
  final AuthController authController = AuthController.instance;
  final FacultyController? facultyController;
  final StudentController? studentController;
  final AdminController? adminController;

  WebView({
    Key? key,
    required this.appBarTitle,
    required this.body,
    required this.selectedWidgetMarker,
    this.showBackButton = false,
    this.appBarActionWidget,
    this.facultyController,
    this.studentController,
    this.adminController,
  }) : super(key: key);

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  AuthController get authController => widget.authController;
  FacultyController? get facultyController => widget.facultyController;
  StudentController? get studentController => widget.studentController;
  AdminController? get adminController => widget.adminController;
  final DateFormat _displayDateFormat = DateFormat('MMMM d, y');
  DateTime? _selectedDate;

  String currentTerm = '';
  String currentYear = '';
  @override
  void initState() {
    // _getConfigData();
    super.initState();
  }

  // void _getConfigData() async {
  //   await _getConfig();
  //   await _getCurrentTerm();
  // }

  Widget _buildNotificationsList(BuildContext context) {
    // Dummy data for notifications
    List<NotificationTile> notifications = const [
      NotificationTile(
        facultyName: 'John Doe',
        content: 'Your attendance has been marked.',
        time: '5 minutes ago',
      ),
      NotificationTile(
        facultyName: 'John Doe',
        content: 'Your attendance has been marked.',
        time: '5 minutes ago',
      ),
      NotificationTile(
        facultyName: 'John Doe',
        content: 'Your attendance has been marked.',
        time: '5 minutes ago',
      ),
    ];

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (BuildContext context, int index) {
        return notifications[index];
      },
    );
  }

  _getConfig() async {
    int userType = authController.loggedInUser?.type.index ?? -1;

    switch (userType) {
      case 0:
        await studentController!.getConfig();
        break;
      case 1:
        await facultyController!.getConfig();
        break;
      default:
        await adminController!.getConfig();
        break;
    }
  }

  _getCurrentTerm() {
    int userType = authController.loggedInUser?.type.index ?? -1;

    setState(() {
      switch (userType) {
        case 0:
          currentTerm = studentController!.config?.currentTerm ?? '';
          currentYear = studentController!.config?.currentYear ?? '';
          break;
        case 1:
          currentTerm = facultyController!.config?.currentTerm ?? '';
          currentYear = facultyController!.config?.currentYear ?? '';
          break;
        default:
          currentTerm = adminController!.config?.currentTerm ?? '';
          currentYear = adminController!.config?.currentYear ?? '';
      }
    });
  }

  _getAttendanceByDate() async {
    int userType = authController.loggedInUser?.type.index ?? -1;

    switch (userType) {
      case 0:
        // await studentController!.getAttendanceAll(
        //   _dateFormat.format(studentController!.dateSelected!),
        // );
        break;
      case 1:
        // await facultyController!.getAttendanceAll(
        //   _dateFormat.format(_selectedDate!),
        // );
        break;
      default:
        await adminController!.getAttendanceAll();
        adminController!.setParams(date: _selectedDate);
    }
  }

  _getController() {
    int userType = authController.loggedInUser?.type.index ?? -1;

    switch (userType) {
      case 0:
        return studentController;

      case 1:
        return facultyController;

      default:
        return adminController;
    }
  }

  _getAttendanceAll() async {
    int userType = authController.loggedInUser?.type.index ?? -1;

    switch (userType) {
      case 0:
        // studentController!.isAllAttendanceCollected = false;
        // studentController!.isAttendanceTodayCollected = false;
        // await studentController!.getAttendanceAll(null);
        // await studentController!.getAttendanceToday();

        break;
      case 1:
        // facultyController!.isAllAttendanceCollected = false;
        // await facultyController!.getAttendanceAll(null);
        break;
      default:
        adminController!.isAllAttendanceCollected = false;
        await adminController!.getAttendanceAll();
    }
  }

  _setSelectedDate(DateTime? date) async {
    int userType = authController.loggedInUser?.type.index ?? -1;
    switch (userType) {
      case 0:
        studentController?.dateSelected = date;
        break;
      case 1:
        // facultyController!.getAttendanceAll(null);
        break;
      default:
        adminController!.getAttendanceAll();
    }
  }

  DateTime? _getSelectedDate() {
    int userType = authController.loggedInUser?.type.index ?? -1;
    switch (userType) {
      case 0:
        print(studentController?.dateSelected);
        return studentController?.dateSelected;
      case 1:
        // facultyController!.getAttendanceAll(null);
        break;
      default:
        adminController!.getAttendanceAll();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/BiSAM.png',
                      height: 40,
                      width: 40,
                    ),
                    const SizedBox(width: 8),
                    const Text('BiSAMS'),
                    const SizedBox(width: 158),
                    Text(widget.appBarTitle),
                  ],
                ),
              ),
              // if (widget.appBarActionWidget == null) _searchBar(context),
            ],
          ),
        ),
        actions: [
          if (widget.appBarActionWidget != null)
            Center(child: widget.appBarActionWidget!),
          if (widget.appBarActionWidget != null)
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                int userType = authController.loggedInUser?.type.index ?? -1;
                switch (userType) {
                  case 0:
                    _showFilterDialog(context, studentController, userType);
                    break;
                  case 1:
                    _showFilterDialog(context, facultyController, userType);
                    break;
                  default:
                    _showFilterDialog(context, adminController!, userType);
                }
              },
            ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
          ),
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _getAttendanceAll();
                  });
                },
              );
            },
          ),
          const SizedBox(
            width: 24,
          )
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SideMenu(
            selectedWidgetMarker: widget.selectedWidgetMarker,
          ),
          Expanded(child: widget.body),
        ],
      ), //
      // endDrawer: Drawer(
      //   child: Column(
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.only(top: 18.0),
      //         child: Text(
      //           'Notifications',
      //           style: Theme.of(context).textTheme.titleLarge,
      //         ),
      //       ),
      //       Expanded(child: _buildNotificationsList(context)),
      //     ],
      //   ),
      // ),
    );
  }
}

void _showFilterDialog(BuildContext context, _dataController, int type) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: FilterForm(_dataController, type),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class FilterForm extends StatefulWidget {
  final dataController;
  int type;
  FilterForm(this.dataController, this.type, {super.key});

  @override
  _FilterFormState createState() => _FilterFormState();
}

class _FilterFormState extends State<FilterForm> {
  DateTime? _date;
  String? _room;
  int? _studentNo;
  int? _facultyNo;
  Remarks? _remarks;
  int? _subjectId;
  int? _schedId;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    // Add form fields for each filter criteria here

    return Column(
      children: [
        // Form fields go here
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DateTimeFormField(
            decoration: InputDecoration(
              labelText: 'Date',
            ),
            initialValue: widget.dataController.date,
            onSaved: (value) {
              _date = value;
              print('Date saved: $_date');
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Room',
            ),
            initialValue: widget.dataController.room,
            onChanged: (value) => _room = value,
          ),
        ),
        Visibility(
          visible: widget.type == 1 && widget.type == 0 ? true : false,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Student No.',
              ),
              initialValue: widget.dataController.studentNo?.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) => _studentNo = int.tryParse(value ?? ''),
            ),
          ),
        ),
        Visibility(
          visible: widget.type == 1 && widget.type == 0 ? true : false,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Faculty No.',
              ),
              initialValue: widget.dataController.facultyNo?.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) => _facultyNo = int.tryParse(value ?? ''),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<Remarks>(
            decoration: InputDecoration(
              labelText: 'Remarks',
            ),
            value: widget.dataController.remarks,
            items: [
              DropdownMenuItem(
                value: null,
                child: Text('Select Remarks'),
              ),
              ...Remarks.values.map((remarks) {
                return DropdownMenuItem<Remarks>(
                  value: remarks,
                  child: Text(remarks.toString().split('.').last),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _remarks = value;
              });
            },
            onSaved: (value) => _remarks = value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Subject Id',
            ),
            initialValue: widget.dataController.subjectId?.toString(),
            keyboardType: TextInputType.number,
            onChanged: (value) => _subjectId = int.tryParse(value ?? ''),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Sched Id',
            ),
            initialValue: widget.dataController.schedId?.toString(),
            keyboardType: TextInputType.number,
            onChanged: (value) => _schedId = int.tryParse(value ?? ''),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DateTimeFormField(
            decoration: InputDecoration(
              labelText: 'From Date',
            ),
            initialValue: null,
            onSaved: (value) => _fromDate = value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DateTimeFormField(
            decoration: InputDecoration(
              labelText: 'To Date',
            ),
            initialValue: null,
            onSaved: (value) => _toDate = value,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Call setParams with the appropriate values
            widget.dataController.setParams(
              date: _date,
              room: _room,
              studentNo: _studentNo,
              facultyNo: _facultyNo,
              remarks: _remarks,
              subjectId: _subjectId,
              schedId: _schedId,
              fromDate: _fromDate,
              toDate: _toDate,
            );
            Navigator.of(context).pop();
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}
