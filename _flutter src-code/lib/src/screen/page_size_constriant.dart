import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/mobile_view.dart';
import 'package:samids_web_app/src/widgets/title_medium_text.dart';

class ScreenSizeWarning extends StatelessWidget {
  static const routeName = '/screen-size-warning';

  const ScreenSizeWarning({Key? key});

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (lbCon, BoxConstraints constraints) {
      if (constraints.maxWidth <= 450) {
        return MobileView(
          routeName: ScreenSizeWarning.routeName,
          currentIndex: 0,
          showAppBar: false,
          showBottomNavBar: false,
          appBarTitle: "Screen Size Warning",
          userName: "",
          body: const [
            SizedBox(height: 200),
            TitleMediumText(title: "Screen Size Warning"),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Text(
                "The current screen size is not compatible with this view. Please switch to a larger screen size to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        );
      } else {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(height: 30),
                TitleMediumText(title: "Screen Size Warning"),
                SizedBox(height: 10),
                Text(
                  "The current screen size is not compatible with this view. Please switch to a larger screen size to continue.",
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
