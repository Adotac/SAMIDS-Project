import 'package:flutter/material.dart';

class MobileView extends StatelessWidget {
  final Widget body;
  final String appBarTitle;
  final String userName;

  const MobileView({
    Key? key,
    required this.body,
    required this.appBarTitle,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
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
      ),
      body: CustomScrollView(
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
              builder: (BuildContext context, BoxConstraints constraints) {
                return FlexibleSpaceBar(
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 0),
                    opacity: constraints.biggest.height > 80 ? 0.0 : 1.0,
                    child: Text(appBarTitle,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  background: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning,',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SingleChildScrollView(
                child: body,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
