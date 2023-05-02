import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/title_medium_text.dart';

class CardSmall extends StatelessWidget {
  final Widget child;
  final String title;
  final int? flexValue;
  final bool isShadow;
  final String leadingText;
  const CardSmall({
    Key? key,
    required this.title,
    required this.child,
    required this.isShadow,
    this.flexValue,
    this.leadingText = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return flexValue == null
        ? _body()
        : Flexible(
            flex: flexValue!,
            child: _body(),
          );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              title != ""
                  ? TitleMediumText(
                      title: title,
                    )
                  : const SizedBox(),
              // ignore: prefer_const_constructors
              Text(
                leadingText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),

          // for (int i = 0; i < 10; i++)
          // ignore: prefer_const_constructors
          child,
        ],
      ),
    );
  }
}
