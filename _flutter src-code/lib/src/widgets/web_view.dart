import 'package:flutter/material.dart';
import 'package:samids_web_app/src/screen/settings.dart';
import 'package:samids_web_app/src/widgets/side_menu.dart';

class WebView extends StatelessWidget {
  final String appBarTitle;
  final Widget body;
  final int selectedWidgetMarker;
  final bool showBackButton;

  WebView({
    Key? key,
    required this.appBarTitle,
    required this.body,
    required this.selectedWidgetMarker,
    this.showBackButton = false,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 250,
                    child: _buildNotificationsList(context),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          SideMenu(selectedWidgetMarker: selectedWidgetMarker),
          Expanded(child: body),
        ],
      ),
    );
  }
}
