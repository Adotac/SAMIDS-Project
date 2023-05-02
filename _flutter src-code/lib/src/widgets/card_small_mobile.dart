import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/title_medium_text.dart';

class MobileSmallCard extends StatelessWidget {
  final bool isShadow;
  final String title;
  final Widget child;
  final String sideTitle;
  final String? sideTitleTrailer;

  const MobileSmallCard({
    Key? key,
    required this.isShadow,
    required this.title,
    required this.child,
    required this.sideTitle,
    this.sideTitleTrailer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: isShadow
            ? const [
                BoxShadow(
                  spreadRadius: -2,
                  blurRadius: 10,
                  color: Colors.black26,
                  offset: Offset(5, 8),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Row(
              children: [
                title.isNotEmpty
                    ? TitleMediumText(title: title)
                    : const SizedBox(),
                const Spacer(),
                Text(sideTitle),
                sideTitleTrailer == null
                    ? const SizedBox()
                    : Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            sideTitleTrailer!,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}
