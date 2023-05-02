import 'package:flutter/material.dart';
import 'package:samids_web_app/src/auth/login.dart';
import 'package:samids_web_app/src/services/auth.services.dart';

class ChangePasswordPage extends StatefulWidget {
  static const routeName = '/reset-password';
  String? token;

  ChangePasswordPage({this.token});
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
        onPressed: () async{
          if(newPassword != null && newPassword == confirmPassword){
              final res = await AuthService.changePassword(newPassword!,null ,widget.token );
              if (res.success) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Password Changed'),
              content: Text('Your password has been changed successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, LoginScreen.routeName);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else{
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Unsuccessful'),
              content: Text("${res.data}"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
          }
          
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
