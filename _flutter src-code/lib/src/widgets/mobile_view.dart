import 'package:flutter/material.dart';
import 'package:samids_web_app/src/screen/page_not_found.dart';

import '../screen/student/attendance.dart';
import '../screen/student/classes.dart';
import '../screen/student/dashboard.dart';

class MobileView extends StatefulWidget {
  final Widget body;
  final String appBarTitle;
  final String userName;
  bool showBottomNavBar;
  bool showAppBar;
  final int currentIndex;
  MobileView({
    Key? key,
    required this.body,
    required this.appBarTitle,
    this.userName = '',
    this.showBottomNavBar = true,
    this.showAppBar = true,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView> {
  BottomNavigationBar _buildBottomNavigationBar(context, int currentIndex) {
    print('currentIndex: $currentIndex');
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.dashboard_outlined,
          ),
          label: 'Dashboard ',
        ),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.event_available_outlined,
            ),
            label: 'Attendance'),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.school_outlined,
          ),
          label: 'Classes',
        ),
      ],
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
            Navigator.of(context).popAndPushNamed(PageNotFound.routeName);
            break;
        }
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
      bottomNavigationBar: Visibility(
        visible: widget.showBottomNavBar,
        child: _buildBottomNavigationBar(context, widget.currentIndex),
      ),
      body: !widget.showAppBar
          ? widget.body
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
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
                    widget.body,
                  ]),
                ),
              ],
            ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     bottomNavigationBar: Visibility(
  //       visible: widget.showBottomNavBar,
  //       child: _buildBottomNavigationBar(context, widget.currentIndex),
  //     ),
  //     body: !widget.showAppBar
  //         ? widget.body
  //         : CustomScrollView(
  //             slivers: [
  //               SliverAppBar(
  //                 leading: IconButton(
  //                   onPressed: () {},
  //                   icon: const Icon(Icons.settings_outlined),
  //                 ),
  //                 leadingWidth: 48,
  //                 automaticallyImplyLeading: false,
  //                 pinned: true,
  //                 floating: true,
  //                 expandedHeight: 100.0,
  //                 flexibleSpace: LayoutBuilder(
  //                   builder:
  //                       (BuildContext context, BoxConstraints constraints) {
  //                     return FlexibleSpaceBar(
  //                       title: AnimatedOpacity(
  //                         duration: const Duration(milliseconds: 0),
  //                         opacity: constraints.biggest.height > 80 ? 0.0 : 1.0,
  //                         child: Text(widget.appBarTitle,
  //                             style: Theme.of(context).textTheme.titleLarge),
  //                       ),
  //                       background: _buildAppBar(widget.currentIndex, context),
  //                     );
  //                   },
  //                 ),
  //               ),
  //               SliverList(
  //                 delegate: SliverChildListDelegate([
  //                   SingleChildScrollView(
  //                     child: widget.body,
  //                   ),
  //                 ]),
  //               ),
  //             ],
  //           ),
  //   );
  // }
}
