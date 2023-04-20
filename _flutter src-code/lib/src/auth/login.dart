import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:samids_web_app/src/auth/controller.dart';
import 'package:samids_web_app/src/auth/register.dart';
import 'package:samids_web_app/src/controllers/auth.controller.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';
import 'package:samids_web_app/src/screen/faculty/dashboard.dart';
import 'package:samids_web_app/src/screen/student/dashboard.dart';

import '../model/faculty_model.dart';
import '../model/student_model.dart';
import '../screen/admin/dashboard.dart';
import '../widgets/responsive_builder.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthViewController _controller = AuthViewController();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _isloading = false;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _usernameController.text = '0000';
//35526 admin

    _passwordController = TextEditingController();
    _passwordController.text = 'admin';
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
        return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              if (isMobile) {
                return _buildMobileView(context);
              } else {
                return _buildWebView(context);
              }
            });
      },
    );
  }

  //add on init
  Future<void> _showResetPasswordDialog(BuildContext context) async {
    String email = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18.0, left: 18.0),
                  child: Image.asset(
                    'assets/images/BiSAM.png',
                    height: 60,
                    width: 60,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'BiSAM - Biometric Smart Attendance Management',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
          ),
          body: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controller.showRegister
                    ? RegisterPage(controller: _controller)
                    : SizedBox(
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
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                          hintText: 'Username'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
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
                    height: 72,
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white),
                      onPressed: () async {
                        await _onLogin(context);
                      },
                      child: _isloading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text("Continue"),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: () => _showResetPasswordDialog(context),
                    child: const Text("Forget password?"),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  TextButton(
                    onPressed: () => {_controller.setShowRegister(true)},
                    child: const Text("Don't have an account? Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _setIsloading(bool value) {
    setState(() {
      _isloading = value;
    });
  }

  Future<void> _onLogin(BuildContext context) async {
    try {
      _errorDialog(
          'Invalid username or password', context, _passwordController);
      _setIsloading(true);
      if (_usernameController.text == '0000' &&
          _passwordController.text == 'admin') {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushNamed(context, AdminDashboard.routeName);
        });
        _setIsloading(false);
        return;
      }

      var success = await AuthController.instance
          .login(_usernameController.text, _passwordController.text);

      if (success) {
        int userType = AuthController.instance.loggedInUser!.type.index;
        print('$userType $userType ');

        if (userType == 0) {
          StudentController.initialize(
            AuthController.instance.loggedInUser!.student as Student,
          );

          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushNamed(context, StudentDashboard.routeName);
          });
          _setIsloading(false);
        } else if (userType == 1) {
          FacultyController.initialize(
              AuthController.instance.loggedInUser!.faculty as Faculty);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushNamed(context, FacultyDashboard.routeName);
          });
        }

        // else if(AuthController.instance.loggedInUser!.type == 2 ) {
        //  WidgetsBinding.instance!.addPostFrameCallback((_) {
        //     Navigator.pushNamed(context, AdminDashboard.routeName);
        //    });
        // }
      } else {
        _setIsloading(false);
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return _errorDialog(
              'Invalid username or password',
              context,
              _passwordController,
            );
          },
        );
      }
    } catch (e) {
      _setIsloading(false);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return _errorDialog(
            '$e',
            context,
            _passwordController,
          );
        },
      );
    }
  }

  Widget _errorDialog(
      String message, BuildContext context, TextEditingController controller) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Error'),
      content: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            controller.clear();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget loginForumFieldMobile(BuildContext context) {
    return _controller.showRegister
        ? RegisterPage(controller: _controller)
        : Container(
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
                        child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white),
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
                      const SizedBox(
                        height: 3,
                      ),
                      TextButton(
                        onPressed: () => {_controller.setShowRegister(true)},
                        child: const Text("Don't have an account? Register"),
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
