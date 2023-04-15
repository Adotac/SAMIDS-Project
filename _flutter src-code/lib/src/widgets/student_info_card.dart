import 'package:flutter/material.dart';
import 'package:samids_web_app/src/model/student_model.dart';
import 'package:samids_web_app/src/widgets/card_small.dart';

import '../controllers/auth.controller.dart';

class StudentInfoCard extends StatelessWidget {
  final currentUser = AuthController.instance;
  final Student student;
  StudentInfoCard({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 154,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                radius: 54,
              ),
              const SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        '${student.firstName} ${student.lastName}',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.headline6!.color,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    student.course,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
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
                      color: Theme.of(context).textTheme.caption!.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
