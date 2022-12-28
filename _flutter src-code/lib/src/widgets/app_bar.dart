import 'package:flutter/material.dart';

class LocalAppBar extends StatelessWidget {
  const LocalAppBar({
    Key? key,
    required this.pageTitle,
  }) : super(key: key);

  final String pageTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.centerLeft,
      height: 60,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(
          pageTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
