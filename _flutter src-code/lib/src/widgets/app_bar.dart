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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: 60,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                pageTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_calendar_outlined),
              ),
              Container(
                alignment: Alignment.centerLeft,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.only(
                    // left: 5.0,
                    right: 18,
                    top: 18,
                    bottom: 18,
                  ),
                  child: Text(
                    "December 31, 2022",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            Theme.of(context).textTheme.titleMedium?.fontSize),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
