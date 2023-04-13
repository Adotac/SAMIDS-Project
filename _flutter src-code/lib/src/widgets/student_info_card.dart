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
    return Card(
      elevation: 0,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${student.firstName} ${student.lastName}',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    student.course,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    currentUser.loggedInUser?.email ?? 'No email',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
