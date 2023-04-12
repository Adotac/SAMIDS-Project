import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile) builder;

  ResponsiveBuilder({Key? key, required this.builder}) : super(key: key);

  static bool isMobile(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width < 768;
  }

  @override
  Widget build(BuildContext context) {
    return builder(context, isMobile(context));
  }
}
