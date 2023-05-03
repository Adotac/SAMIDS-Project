import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:samids_web_app/src/screen/page_not_found.dart';

import '../auth/login.dart';
import '../controllers/admin_controller.dart';
import '../controllers/auth.controller.dart';
import '../screen/admin/attendance.dart';
import '../screen/admin/dashboard.dart';
import '../screen/faculty/attendance.dart';
import '../screen/faculty/classes.dart';
import '../screen/faculty/dashboard.dart';
import '../screen/settings.dart';
import '../screen/student/attendance.dart';
import '../screen/student/classes.dart';
import '../screen/student/dashboard.dart';
import 'notification_tile_list.dart';

class MobileView extends StatefulWidget {
  final List<Widget> body;
  final String appBarTitle;
  final String userName;
  bool showBottomNavBar;
  bool showAppBar;
  bool appBarOnly;
  bool implyLeading;
  bool isAdmin = false;

  final String routeName;
  final int currentIndex;
  MobileView(
      {Key? key,
      required this.body,
      required this.appBarTitle,
      required this.currentIndex,
      this.userName = '',
      this.isAdmin = false,
      this.showBottomNavBar = true,
      this.showAppBar = true,
      this.appBarOnly = false,
      this.implyLeading = false,
      required this.routeName})
      : super(key: key);
  final AuthController authController = AuthController.instance;
  @override
  State<MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView> {
  AuthController get _authController => widget.authController;

  Widget _buildBottomNavigationBar(context, int currentIndex) {
    // Get the current theme's brightness
    Brightness brightness = Theme.of(context).brightness;

    // Set the unselected item color based on the current theme's brightness
    Color unselectedItemColor =
        brightness == Brightness.dark ? Colors.white : Colors.grey;

    Color selectedItemColor = Theme.of(context).primaryColor;

    // Define selected icons
    List<IconData> selectedIcons = [
      Icons.dashboard,
      Icons.event_available,
      Icons.school,
      Icons.settings,
    ];

    // Define unselected icons
    List<IconData> unselectedIcons = [
      Icons.dashboard_outlined,
      Icons.event_available_outlined,
      Icons.school_outlined,
      Icons.settings_outlined,
    ];
    List<String> labels;
    // Define labels
    if (widget.isAdmin) {
      labels = [
        'Dashboard',
        'Attendance',
      ];
    } else {
      labels = [
        'Dashboard',
        'Attendance',
        'Classes',
        'Settings',
      ];
    }

    List<BottomNavigationBarItem> items = List.generate(
      widget.isAdmin ? 2 : 4,
      (index) => BottomNavigationBarItem(
        icon: Icon(
          currentIndex == index ? selectedIcons[index] : unselectedIcons[index],
          color:
              currentIndex == index ? selectedItemColor : unselectedItemColor,
        ),
        label: labels[index],
      ),
    );

    return BottomNavigationBar(
      currentIndex: currentIndex,
      // selectedLabelStyle:
      //     TextStyle(fontWeight: FontWeight.bold, color: selectedItemColor),
      // unselectedLabelStyle:
      //     TextStyle(fontWeight: FontWeight.normal, color: unselectedItemColor),
      selectedItemColor: selectedItemColor,
      items: items,
      onTap: (int index) {
        int userType = _authController.loggedInUser?.type.index ?? -1;
        switch (index) {
          case 0:
            switch (userType) {
              case 0:
                Navigator.popAndPushNamed(context, StudentDashboard.routeName);
                break;
              case 1:
                Navigator.popAndPushNamed(context, FacultyDashboard.routeName);
                break;
              default:
                Navigator.popAndPushNamed(
                  context,
                  AdminDashboard.routeName,
                );
            }

            break;
          case 1:
            switch (userType) {
              case 0:
                Navigator.popAndPushNamed(context, StudentAttendance.routeName);
                break;
              case 1:
                Navigator.popAndPushNamed(context, FacultyAttendance.routeName);
                break;

              default:
                Navigator.popAndPushNamed(
                  context,
                  AdminAttendance.routeName,
                );
            }
            break;
          case 2:
            switch (userType) {
              case 0:
                Navigator.popAndPushNamed(context, StudentClasses.routeName);
                break;
              case 1:
                Navigator.popAndPushNamed(context, FacultyClasses.routeName);
                break;

              default:
                Navigator.popAndPushNamed(
                  context,
                  AdminAttendance.routeName,
                );
            }
            break;
          case 3:
            Navigator.of(context).popAndPushNamed(SettingsPage.routeName);

            break;
          default:
            Navigator.of(context).popAndPushNamed(PageNotFound.routeName);
        }
      },
    );
  }

  // Widget _buildNotificationsList(BuildContext context) {
  //   // Dummy data for notifications
  //   List<NotificationTile> notifications = const [
  //     NotificationTile(
  //       facultyName: 'John Doe',
  //       content: 'Your attendance has been marked.',
  //       time: '5 minutes ago',
  //     ),
  //     NotificationTile(
  //       facultyName: 'John Doe',
  //       content: 'Your attendance has been marked.',
  //       time: '5 minutes ago',
  //     ),
  //     NotificationTile(
  //       facultyName: 'John Doe',
  //       content: 'Your attendance has been marked.',
  //       time: '5 minutes ago',
  //     ),
  //   ];

  //   return ListView.builder(
  //     itemCount: notifications.length,
  //     itemBuilder: (BuildContext context, int index) {
  //       return notifications[index];
  //     },
  //   );
  // }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Widget _buildGreetingText(
    context,
    String userName, [
    String? greeting,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (greeting != null)
            Text(
              greeting,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          Text(
            userName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(int currentIndex, context) {
    switch (currentIndex) {
      case 0:
        return _buildGreetingText(context, widget.userName, _getGreeting());

      case 1:
      case 2:
        return _buildGreetingText(context, widget.appBarTitle);

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Visibility(
        visible: widget.showBottomNavBar,
        child: _buildBottomNavigationBar(context, widget.currentIndex),
      ),
      appBar: widget.appBarOnly
          ? AppBar(
              actions: [
                Builder(
                  builder: (BuildContext context) {
                    if (widget.isAdmin) {
                      return IconButton(
                        icon: const Icon(Icons.logout_outlined),
                        onPressed: () {
                          GetIt.instance.unregister<AdminController>();

                          _authController.logout();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              LoginScreen.routeName,
                              (Route<dynamic> route) => false);
                        },
                      );
                    }
                    return const SizedBox();
                    // IconButton(
                    //   icon: const Icon(Icons.notifications_outlined),
                    //   onPressed: () {
                    //     Scaffold.of(context).openEndDrawer();
                    //   },
                    // );
                  },
                ),
              ],
              leading: Visibility(
                visible: !widget.implyLeading,
                child: Container(
                  margin: const EdgeInsets.only(left: 16),
                  child: Image.asset(
                    'assets/images/BiSAM.png',
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
              automaticallyImplyLeading: widget.implyLeading,
              leadingWidth: 48,
              title: Text(widget.appBarTitle),
            )
          : null,
      body: (!widget.showAppBar || widget.appBarOnly)
          ? RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  Navigator.popAndPushNamed(context, widget.routeName);
                });
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [...widget.body],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    actions: [
                      Builder(
                        builder: (BuildContext context) {
                          return const SizedBox();

                          // IconButton(
                          //   icon: const Icon(Icons.notifications_outlined),
                          //   onPressed: () {
                          //     Scaffold.of(context).openEndDrawer();
                          //   },
                          // );
                        },
                      ),
                    ],
                    leading: Visibility(
                      visible: !widget.implyLeading,
                      child: Container(
                        margin: const EdgeInsets.only(left: 16),
                        child: Image.asset(
                          'assets/images/BiSAM.png',
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ),
                    leadingWidth: 48,
                    automaticallyImplyLeading: widget.implyLeading,
                    pinned: true,
                    floating: true,
                    expandedHeight: 100.0,
                    flexibleSpace: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return FlexibleSpaceBar(
                          title: AnimatedOpacity(
                            duration: const Duration(milliseconds: 0),
                            opacity:
                                constraints.biggest.height > 80 ? 0.0 : 1.0,
                            child: Text(widget.appBarTitle,
                                style: Theme.of(context).textTheme.titleLarge),
                          ),
                          background:
                              _buildAppBar(widget.currentIndex, context),
                        );
                      },
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      ...widget.body,
                    ]),
                  ),
                ],
              ),
            ),
    );
  }
}
