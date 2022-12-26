// ignore_for_file: prefer_const_constructors

import 'dart:html';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  LoginScreen({super.key});

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final Widget backgroundImage = Image.asset(
    fit: BoxFit.cover,
    height: double.infinity,
    width: double.infinity,
    alignment: Alignment.center,
    'assets/images/cloud_login_background.png',
  );

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      backgroundImage,
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.black,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              SizedBox(
                height: 40,
              ),
              const Text(
                'SAMIDS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          actions: const [],
        ),
        body: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              child: Container(
                color: Colors.transparent,
                child: Column(
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
                              Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Email',
                                      hintText: 'Enter your username'),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Password',
                                      hintText: 'Enter your secure password'),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                height: 60,
                                width: double.infinity,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white),
                                  onPressed: () {
                                    // Navigator.pushReplacementNamed(
                                    //     context, routeAppView);
                                  },
                                  child: Text("Continue"),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextButton(
                                onPressed: () {
                                  forgetPass(context);
                                },
                                child: Text("Forget password?"),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                  // child: Text("data"),
                  ),
            )
          ],
        ),
      ),
    ]);
  }

  Future<String?> forgetPass(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          "Forget Password?",
          style: TextStyle(
            color: Theme.of(context).errorColor,
          ),
        ),
        content: Text(
          'Please request new password from admin',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => {Navigator.pop(context)},
            child: Text(
              'OK',
            ),
          ),
        ],
      ),
    );
  }
}

final snackBarError = SnackBar(
  backgroundColor: Colors.red,
  content: const Text(
    'Error: Incorrect email or password ',
    style: TextStyle(
      color: Colors.white,
    ),
  ),
  action: SnackBarAction(
    textColor: Colors.white,
    label: 'ok',
    onPressed: () {
      // Some code to undo the change.
    },
  ),
);

final snackBarMissing = SnackBar(
  backgroundColor: Colors.red,
  content: const Text(
    'Error: Missing fields for email or password ',
    style: TextStyle(
      color: Colors.white,
    ),
  ),
  action: SnackBarAction(
    textColor: Colors.white,
    label: 'ok',
    onPressed: () {
      // Some code to undo the change.
    },
  ),
);
