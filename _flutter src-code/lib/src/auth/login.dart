import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:samids_web_app/src/controllers/auth.controller.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';
import 'package:samids_web_app/src/screen/faculty/dashboard.dart';
import 'package:samids_web_app/src/screen/student/dashboard.dart';

import '../model/faculty_model.dart';
import '../model/student_model.dart';
import '../widgets/responsive_builder.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _isloading = false;

  @override
  void initState() {
    _usernameController = TextEditingController()..text = '46382';
    _passwordController = TextEditingController()..text = 'test123';
    super.initState();
  }

  Widget _backgroundImage(bool isMobile) => Image.asset(
        'assets/images/cloud_login_background.png',
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: isMobile ? const Alignment(.3, .1) : Alignment.center,
      );

  Widget _loginForumField(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Login",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'Enter your username',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => _showResetPasswordDialog(context),
          child: const Text("Forget password?"),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            // Handle register navigation here
          },
          child: const Text("Register"),
          style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              )),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, isMobile) {
        return Stack(
          children: [
            Container(color: Colors.white),
            _backgroundImage(isMobile),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'BiSAM',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: isMobile
                    ? _loginFormMobile(context)
                    : _loginFormWeb(context),
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget _backgroundImage(bool isMobile) {
  //   return Image.asset(
  //     'assets/images/cloud_login_background.png',
  //     fit: BoxFit.cover,
  //     height: double.infinity,
  //     width: double.infinity,
  //     alignment: isMobile ? const Alignment(.3, .1) : Alignment.center,
  //   );
  // }

  Widget _loginFormMobile(BuildContext context) {
    return _loginForm(context, true);
  }

  Widget _loginFormWeb(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 450,
            height: 600,
            child: SingleChildScrollView(
              child: _loginForm(context, false),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
          ),
        ],
      ),
    );
  }

  Widget _loginForm(BuildContext context, bool isMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: isMobile ? null : 420,
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
                  _usernameField(),
                  _passwordField(),
                  const SizedBox(
                    height: 20,
                  ),
                  _loginButton(context),
                  const SizedBox(
                    height: 10,
                  ),
                  _forgotPasswordButton(context),
                  _registerButton(context), // Added "Register" button
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _usernameField() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _usernameController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Username',
          hintText: 'Username',
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Password',
          hintText: 'Enter your secure password',
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 72,
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
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
    );
  }

  Widget _forgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () => _showResetPasswordDialog(context),
      child: const Text("Forget password?"),
    );
  }

  Widget _registerButton(BuildContext context) {
    return TextButton(
      onPressed: () => _navigateToRegisterPage(context),
      child: const Text("Don't have an account? Register"),
    );
  }

  Future<void> _onLogin(BuildContext context) async {
    setState(() {
      _isloading = true;
    });

    try {
      // Authenticate the user here
      // final result = await _authService.login(
      //   username: _usernameController.text,
      //   password: _passwordController.text,
      // );

      // if (result != null) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => HomePage()),
      //   );
      // } else {
      //   _showErrorDialog(context, 'Invalid credentials');
      // }
    } catch (e) {
      _showErrorDialog(context, e.toString());
    } finally {
      setState(() {
        _isloading = false;
      });
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
// Implement the reset password dialog
  }

  void _navigateToRegisterPage(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => RegisterPage()),
    // );
  }
}
