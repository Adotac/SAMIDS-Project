import 'package:flutter/material.dart';
import 'package:samids_web_app/src/screen/page_not_found.dart';

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
  final int currentIndex;
  MobileView({
    Key? key,
    required this.body,
    required this.appBarTitle,
    required this.currentIndex,
    this.userName = '',
    this.showBottomNavBar = true,
    this.showAppBar = true,
    this.appBarOnly = false,
  }) : super(key: key);

  @override
  State<MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView> {
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

    // Define labels
    List<String> labels = [
      'Dashboard',
      'Attendance',
      'Classes',
      'Settings',
    ];

    List<BottomNavigationBarItem> items = List.generate(
      4,
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
        switch (index) {
          case 0:
            Navigator.of(context).popAndPushNamed(StudentDashboard.routeName);
            break;
          case 1:
            Navigator.of(context).popAndPushNamed(StudentAttendance.routeName);
            break;
          case 2:
            Navigator.of(context).popAndPushNamed(StudentClasses.routeName);
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
      endDrawer: Drawer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(child: _buildNotificationsList(context)),
          ],
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: widget.showBottomNavBar,
        child: _buildBottomNavigationBar(context, widget.currentIndex),
      ),
      appBar: widget.appBarOnly
          ? AppBar(
              actions: [
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    );
                  },
                ),
              ],
              leading: Container(
                margin: const EdgeInsets.only(left: 16),
                child: Image.asset(
                  'assets/images/BiSAM.png',
                  height: 24,
                  width: 24,
                ),
              ),
              automaticallyImplyLeading: false,
              leadingWidth: 48,
              title: Text(widget.appBarTitle),
            )
          : null,
      body: (!widget.showAppBar || widget.appBarOnly)
          ? SingleChildScrollView(
              child: Column(
                children: [...widget.body],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  actions: [
                    Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                        );
                      },
                    ),
                  ],
                  leading: Container(
                    margin: const EdgeInsets.only(left: 16),
                    child: Image.asset(
                      'assets/images/BiSAM.png',
                      height: 24,
                      width: 24,
                    ),
                  ),
                  leadingWidth: 48,
                  automaticallyImplyLeading: false,
                  pinned: true,
                  floating: true,
                  expandedHeight: 100.0,
                  flexibleSpace: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return FlexibleSpaceBar(
                        title: AnimatedOpacity(
                          duration: const Duration(milliseconds: 0),
                          opacity: constraints.biggest.height > 80 ? 0.0 : 1.0,
                          child: Text(widget.appBarTitle,
                              style: Theme.of(context).textTheme.titleLarge),
                        ),
                        background: _buildAppBar(widget.currentIndex, context),
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
    );
  }
}
