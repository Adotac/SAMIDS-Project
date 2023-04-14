// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Icon leadingIcon;
  final String title;
  final Widget subtitle;
  final String trailingText;
  final String subTrailingText;
  final double spaceBetween = 6.0;
  final Color leadingColors;
  const CustomListTile({
    Key? key,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.trailingText,
    required this.subTrailingText,
    required this.leadingColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).primaryColor,
            ),
            child: leadingIcon,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: spaceBetween),
                subtitle,
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trailingText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: spaceBetween),
              Text(
                subTrailingText,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
