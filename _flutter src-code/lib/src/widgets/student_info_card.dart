import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:samids_web_app/src/model/student_model.dart';
import 'package:samids_web_app/src/widgets/line_chart.dart';

import '../controllers/auth.controller.dart';

// ignore: must_be_immutable
class StudentInfoCard extends StatelessWidget {
  final currentUser = AuthController.instance;
  final String firstName;
  final String lastName;
  bool isFaculty;

  StudentInfoCard(
      {Key? key,
      this.isFaculty = false,
      required this.firstName,
      required this.lastName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user;
    return Container(
      constraints:
          const BoxConstraints(maxHeight: 148, minWidth: double.infinity),
      padding: const EdgeInsets.only(left: 26),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/montero.jpg'),
              radius: 40,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    text: '$firstName $lastName ',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge!.color,
                    ),
                    children: [
                      isFaculty
                          ? TextSpan(
                              text: ' Faculty',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : const TextSpan(
                              text: '',
                            ),
                    ],
                  ),
                ),
                Text(
                  "Department of Computer Studies",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    // ignore: deprecated_member_use
                    color: Theme.of(context).textTheme.subtitle1!.color,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  currentUser.loggedInUser?.email ?? 'No email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
