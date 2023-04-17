import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:samids_web_app/src/model/student_model.dart';

import '../controllers/auth.controller.dart';

class StudentInfoCard extends StatelessWidget {
  final currentUser = AuthController.instance;
  final Student user;
  bool isFaculty;

  StudentInfoCard({Key? key, required this.user, this.isFaculty = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          const BoxConstraints(maxHeight: 142, minWidth: double.infinity),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    text: '${user.firstName} ${user.lastName} ',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge!.color,
                    ),
                    children: [
                      isFaculty
                          ? TextSpan(
                              text: 'Faculty',
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
          ),
        ),
      ),
    );
  }
}
