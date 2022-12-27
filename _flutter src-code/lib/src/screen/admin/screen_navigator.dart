import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../constant/constant_values.dart';

class ScreenNavigator extends StatelessWidget {
  const ScreenNavigator({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pageTitle = getTitleByIndex(controller.selectedIndex);
        return Text(
          pageTitle,
          style: theme.textTheme.headlineSmall,
        );
      },
    );
  }

  // Widget body(BuildContext context) {
  //   return Column(
  //     children: [
  //       Container(
  //         alignment: Alignment.centerLeft,
  //         // color: Colors.red,
  //         height: 60,
  //         child: Padding(
  //           padding: const EdgeInsets.all(18.0),
  //           child: Text(
  //             pageTitle,
  //             style: Theme.of(context).textTheme.titleLarge,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
