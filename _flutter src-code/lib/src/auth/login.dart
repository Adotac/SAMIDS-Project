import 'package:flutter/material.dart';
import 'package:samids_web_app/src/controllers/auth.controller.dart';
import 'package:samids_web_app/src/controllers/student_dashboard.controller.dart';
import 'package:samids_web_app/src/screen/student/dashboard.dart';
import 'package:samids_web_app/src/services/DTO/login_user.dart';

import '../model/student_model.dart';
import '../widgets/responsive_builder.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _usernameController.text = '2004';

    _passwordController = TextEditingController();
    _passwordController.text = 'test123';
    super.initState();
  }

  final Widget backgroundImage = Image.asset(
    fit: BoxFit.cover,
    height: double.infinity,
    width: double.infinity,
    alignment: Alignment.center,
    'assets/images/cloud_login_background.png',
  );

  final Widget backgroundImageMobile = Image.asset(
    fit: BoxFit.cover,
    height: double.infinity,
    width: double.infinity,
    alignment: const Alignment(.3, .1),
    'assets/images/cloud_login_background.png',
  );

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, isMobile) {
        if (isMobile) {
          return _buildMobileView(context);
        } else {
          return _buildWebView(context);
        }
      },
    );
  }

  //add on init
  Future<void> _showResetPasswordDialog(BuildContext context) async {
    String email = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        title: Text(
          'Reset Password',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                email = value;
              },
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Username',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (isValidEmail(email)) {
                // send email password reset
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(
                      'Password Reset',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    content: RichText(
                      text: TextSpan(
                        text: 'An email for password reset has been sent to ',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                        children: [
                          TextSpan(
                            text: email,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                // show invalid email error
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(
                      'Invalid Email',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    content: const Text('Please enter a valid email address'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  bool isValidEmail(String email) {
    RegExp regExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regExp.hasMatch(email);
  }

  // Widget _buildMobileView(BuildContext context) {
  //   return Stack(
  //     children: [
  //       Container(
  //           color: Colors.white), // Add this line to set a white background
  //       backgroundImageMobile,
  //       Scaffold(
  //         backgroundColor: Colors.transparent,
  //         appBar: AppBar(
  //           automaticallyImplyLeading: false,
  //           backgroundColor: Colors.transparent,
  //           elevation: 0,
  //           title: const Text(
  //             'SAMSS',
  //             style:
  //                 TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
  //           ),
  //         ),
  //         body: loginForumFieldMobile(context),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildMobileView(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
        ),
        backgroundImageMobile,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'BiSAM',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: loginForumFieldMobile(context),
          ),
        ),
      ],
    );
  }

  Widget _buildWebView(BuildContext context) {
    return Stack(
      children: [
        backgroundImage,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'BiSAM',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          body: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 450,
                  height: 600,
                  child: SingleChildScrollView(
                    child: loginForumWeb(context),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildWebView(BuildContext context) {
  //   return Stack(
  //     children: [
  //       backgroundImage,
  //       Scaffold(
  //         backgroundColor: Colors.transparent,
  //         appBar: AppBar(
  //           automaticallyImplyLeading: false,
  //           backgroundColor: Colors.transparent,
  //           elevation: 0,
  //           // remove the back button
  //           title: const Text(
  //             'SAMS',
  //             style:
  //                 TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
  //           ),
  //         ),
  //         body: Center(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               SizedBox(
  //                 width: 450,
  //                 height: 600,
  //                 child: loginForumWeb(context),
  //               ),
  //               SizedBox(
  //                 width: MediaQuery.of(context).size.width * 0.3,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Column loginForumWeb(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 420,
          width: 370,
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                          hintText: 'Username'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          hintText: 'Enter your secure password'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: 60,
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white),
                      onPressed: () async {
                        await _onLogin(context);
                      },
                      child: const Text("Continue"),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: () => _showResetPasswordDialog(context),
                    child: const Text("Forget password?"),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onLogin(BuildContext context) async {
    try {
      var success = await AuthController.instance
          .login(_usernameController.text, _passwordController.text);
      if (success) {
        StudentDashboardController.initialize(
            AuthController.instance.loggedInUser!.student as Student);

        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushNamed(context, StudentDashboard.routeName);
        });
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Row(
              children: const [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Expanded(child: Text('Invalid username or password')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _passwordController.clear();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Widget loginForumFieldMobile(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Login",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            constraints: const BoxConstraints(
              maxWidth: 370,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _onLogin(context);
                    },
                    child: const Text("Continue"),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () => _showResetPasswordDialog(context),
                  child: const Text("Forget password?"),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
