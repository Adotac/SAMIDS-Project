import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
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
    _getConfigData();
    super.initState();
  }

  void _getConfigData() async {
    await _getConfig();
    await _getCurrentTerm();
  }

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
        await studentController!.getAttendanceAll(
          _dateFormat.format(studentController!.dateSelected!),
        );
        break;
      case 1:
        await facultyController!.getAttendanceAll(
          _dateFormat.format(_selectedDate!),
        );
        break;
      default:
        await adminController!.getAttendanceAll(
          _dateFormat.format(_selectedDate!),
        );
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
        studentController!.isAllAttendanceCollected = false;
        studentController!.isAttendanceTodayCollected = false;
        await studentController!.getAttendanceAll(null);
        await studentController!.getAttendanceToday();

        break;
      case 1:
        facultyController!.isAllAttendanceCollected = false;
        await facultyController!.getAttendanceAll(null);
        break;
      default:
        adminController!.isAllAttendanceCollected = false;
        await adminController!.getAttendanceAll(null);
    }
  }

  _setSelectedDate(DateTime? date) async {
    int userType = authController.loggedInUser?.type.index ?? -1;
    switch (userType) {
      case 0:
        studentController?.dateSelected = date;
        break;
      case 1:
        facultyController!.getAttendanceAll(null);
        break;
      default:
        adminController!.getAttendanceAll(null);
    }
  }

  DateTime? _getSelectedDate() {
    int userType = authController.loggedInUser?.type.index ?? -1;
    switch (userType) {
      case 0:
        print(studentController?.dateSelected);
        return studentController?.dateSelected;
      case 1:
        facultyController!.getAttendanceAll(null);
        break;
      default:
        adminController!.getAttendanceAll(null);
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
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
          ),
          // Visibility(
          //   visible: widget.appBarTitle != "Settings",
          //   child: Center(
          //     child: Text(
          //       _getSelectedDate() == null
          //           ? '$currentTerm-$currentYear'
          //           : _displayDateFormat.format(_getSelectedDate()!),
          //       style: TextStyle(
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //         color: Theme.of(context).textTheme.titleLarge?.color,
          //       ),
          //     ),
          //   ),
          // ),
          // Visibility(
          //   visible: widget.appBarTitle != "Settings",
          //   child: IconButton(
          //     icon: const Icon(Icons.date_range),
          //     onPressed: () async {
          //       DateTime? selectedDate = await showDatePicker(
          //         selectableDayPredicate: (date) =>
          //             date.isBefore(DateTime.now()),
          //         context: context,
          //         initialDate: _selectedDate ?? DateTime.now(),
          //         firstDate: DateTime.now().subtract(const Duration(days: 365)),
          //         lastDate: DateTime.now().add(const Duration(days: 365)),
          //       );
          //       if (selectedDate != null) {
          //         setState(() {
          //           _setSelectedDate(selectedDate);
          //           _getAttendanceByDate();
          //         });
          //       } else {
          //         _getAttendanceAll();
          //       }
          //     },
          //   ),
          // ),
          // Builder(
          //   builder: (BuildContext context) {
          //     return IconButton(
          //       icon: const Icon(Icons.notifications_none_outlined),
          //       onPressed: () {
          //         Scaffold.of(context).openEndDrawer();
          //       },
          //     );
          //   },
          // ),
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
