import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/title_medium_text.dart';

class CardSmall extends StatelessWidget {
  final Widget sampleData;
  final String title;
  const CardSmall({
    Key? key,
    required this.title, required this.sampleData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Flexible(
      flex: 1,
      child: Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                TitleMediumText(
                  title: title,
                ),
                for (int i = 0; i < 10; i++)
                  // ignore: prefer_const_constructors
                  sampleData,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
