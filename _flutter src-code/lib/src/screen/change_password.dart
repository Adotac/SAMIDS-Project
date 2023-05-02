import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  static const routeName = '/change-password';
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  String? newPassword;
  String? confirmPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'New Password',
                hintText: 'Enter new password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  newPassword = value;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter new password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  confirmPassword = value;
                });
              },
            ),
            if (newPassword != null &&
                confirmPassword != null &&
                newPassword != confirmPassword)
              Text(
                'Passwords do not match.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Your onPressed logic here
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
