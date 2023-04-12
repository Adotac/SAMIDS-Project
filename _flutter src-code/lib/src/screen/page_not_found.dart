// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/mobile_view.dart';
import 'package:samids_web_app/src/widgets/title_medium_text.dart';

class PageNotFound extends StatelessWidget {
  static const routeName = '/page-not-found';

  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
      if (constraints.maxWidth <= 450) {
        return MobileView(
          appBarTitle: "Page Not Found",
          userName: "",
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/page_not_found.png",
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 30),
                TitleMediumText(title: "Page Not Found"),
                SizedBox(height: 10),
                Text(
                  "The requested page couldn't be found",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/page_not_found.png",
                  width: 400,
                  height: 400,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 30),
                TitleMediumText(title: "Page Not Found"),
                SizedBox(height: 10),
                Text(
                  "The requested page couldn't be found",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }
}
