// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/mobile_view.dart';
import 'package:samids_web_app/src/widgets/title_medium_text.dart';

class PageNotFound extends StatelessWidget {
  static const routeName = '/page-not-found';

  const PageNotFound({super.key});

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
      if (constraints.maxWidth <= 450) {
        return MobileView(
            routeName: PageNotFound.routeName,
            currentIndex: 0,
            showAppBar: false,
            showBottomNavBar: false,
            appBarTitle: "Page Not Found",
            userName: "",
            body: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => navigateBack(context),
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
            ]);
      } else {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => navigateBack(context),
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
