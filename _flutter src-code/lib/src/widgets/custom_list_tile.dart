import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final Widget subtitle;
  final String trailingText;
  final String subTrailingText;
  final double spaceBetween = 6.0;

  const CustomListTile({
    Key? key,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.trailingText,
    required this.subTrailingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Icon(leadingIcon)),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: spaceBetween),
              Text(subTrailingText),
            ],
          ),
        ],
      ),
    );
  }
}
