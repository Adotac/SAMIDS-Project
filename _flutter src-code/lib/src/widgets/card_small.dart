import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/title_medium_text.dart';

class CardSmall extends StatelessWidget {
  final Widget child;
  final String title;
  final int flexValue;
  const CardSmall({
    Key? key,
    required this.title,
    required this.child,
    this.flexValue = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flexValue,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              title != ""
                  ? TitleMediumText(
                      title: title,
                    )
                  : const SizedBox(),
              // for (int i = 0; i < 10; i++)
              // ignore: prefer_const_constructors
              child,
            ],
          ),
        ),
      ),
    );
  }
}
