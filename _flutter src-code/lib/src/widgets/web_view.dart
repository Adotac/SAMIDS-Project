import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samids_web_app/src/widgets/notification_tile_list.dart';
import 'package:samids_web_app/src/widgets/side_menu.dart';

enum FilterOptions { subjectId, date, time }

class WebView extends StatefulWidget {
  final String appBarTitle;
  final Widget body;
  final int selectedWidgetMarker;
  final bool showBackButton;
  final Widget? appBarActionWidget;

  WebView({
    Key? key,
    required this.appBarTitle,
    required this.body,
    required this.selectedWidgetMarker,
    this.showBackButton = false,
    this.appBarActionWidget,
  }) : super(key: key);

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayDateFormat = DateFormat('MMMM d, y');
  DateTime _selectedDate = DateTime.now();

  List<Widget> _appBarActions(BuildContext context) {
    switch (widget.appBarTitle) {
      case 'Dashboard':
        return [
          Center(
            child: Text(
              _displayDateFormat.format(_selectedDate),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
          ),
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(Duration(days: 365)),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (selectedDate != null) {
                setState(() {
                  _selectedDate = selectedDate;
                });
              }
            },
          ),
        ];
      case 'Attendance':
        return [
          _searchBar(context),
        ];
      case 'Settings':
        return [];
      default:
        return [];
    }
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
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<FilterOptions>(
                icon: const Icon(Icons.filter_list),
                onSelected: (FilterOptions filterOption) {
                  // Implement your filter selection logic here
                  switch (filterOption) {
                    case FilterOptions.subjectId:
                      // Filter by subject id
                      break;
                    case FilterOptions.date:
                      // Filter by date
                      break;
                    case FilterOptions.time:
                      // Filter by time
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<FilterOptions>(
                      value: FilterOptions.subjectId,
                      child: Text('Filter by Subject ID'),
                    ),
                    PopupMenuItem<FilterOptions>(
                      value: FilterOptions.date,
                      child: Text('Filter by Date'),
                    ),
                    PopupMenuItem<FilterOptions>(
                      value: FilterOptions.time,
                      child: Text('Filter by Time'),
                    ),
                  ];
                },
              ),
              Icon(Icons.search_outlined, color: Theme.of(context).hintColor),
              const SizedBox(width: 12)
            ],
          ),
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
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/BiSAM.png',
                      height: 40,
                      width: 40,
                    ),
                    const SizedBox(width: 8),
                    Text('BiSAMS'),
                    const SizedBox(width: 158),
                    Text(widget.appBarTitle),
                  ],
                ),
              ),
              if (widget.appBarActionWidget != null) ...[
                widget.appBarActionWidget!
              ],
              // if (widget.appBarActionWidget == null) _searchBar(context),
            ],
          ),
        ),
        actions: [
          Visibility(
            visible: widget.appBarTitle == "Dashboard",
            child: Center(
              child: Text(
                _displayDateFormat.format(_selectedDate),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),
          ),
          Visibility(
            visible: widget.appBarTitle == "Dashboard",
            child: IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selectedDate != null) {
                  setState(() {
                    _selectedDate = selectedDate;
                  });
                }
              },
            ),
          ),
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
