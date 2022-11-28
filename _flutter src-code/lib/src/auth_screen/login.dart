// ignore_for_file: prefer_const_constructors

import 'dart:html';

import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final Widget networkSvg = Expanded(
    child: Container(
      child: Image.asset(
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
        'assets/images/cloud_login_background.png',
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.black,
        elevation: 0,
        title: const Text(
          'SAMIDS',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: const [],
      ),
      body: Stack(children: [
        networkSvg,
        Row(
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
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Username',
                                      hintText: 'Enter your username'),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: TextField(
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
                                  onPressed: () {},
                                  child: Text("Continue"),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextButton(
                                onPressed: () {},
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
      ]),
    );
  }
}
