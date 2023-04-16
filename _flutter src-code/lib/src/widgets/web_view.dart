import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:samids_web_app/src/screen/settings.dart';
import 'package:samids_web_app/src/widgets/side_menu.dart';

class WebView extends StatelessWidget {
  final String appBarTitle;
  final Widget body;
  final int selectedWidgetMarker;
  final bool showBackButton;
  final Widget? appBarActionWidget;

  const WebView({
    Key? key,
    required this.appBarTitle,
    required this.body,
    required this.selectedWidgetMarker,
    this.showBackButton = false,
    this.appBarActionWidget,
  }) : super(key: key);

  Widget _buildNotificationsList(BuildContext context) {
    // Dummy data for notifications
    List<String> notifications = [
      'Notification 1',
      'Notification 2',
      'Notification 3',
    ];

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(notifications[index]),
        );
      },
    );
  }

  Widget _searchBar(BuildContext context) {
    ThemeData currentTheme = Theme.of(context);
    return Container(
      width: 500,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        onSubmitted: (textEditingController) {
          if (kDebugMode) {
            print(textEditingController.toString());
          }
        },
        // controller: _textEditingController,
        decoration: InputDecoration(
          suffixIcon:
              Icon(Icons.search_outlined, color: Theme.of(context).hintColor),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: currentTheme.hintColor),
        ),
      ),
    );
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
                child: Text(appBarTitle),
              ),
              if (appBarActionWidget != null) _searchBar(context),
            ],
          ),
        ),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.notifications_none_outlined),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SideMenu(
            selectedWidgetMarker: selectedWidgetMarker,
          ),
          Expanded(child: body),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(child: _buildNotificationsList(context)),
          ],
        ),
      ),
    );
  }
}
