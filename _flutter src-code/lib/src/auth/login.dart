import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:samids_web_app/src/auth/controller.dart';
import 'package:samids_web_app/src/auth/register.dart';
import 'package:samids_web_app/src/controllers/admin_controller.dart';
import 'package:samids_web_app/src/controllers/auth.controller.dart';
import 'package:samids_web_app/src/controllers/faculty_controller.dart';
import 'package:samids_web_app/src/controllers/student_controller.dart';
import 'package:samids_web_app/src/screen/faculty/dashboard.dart';
import 'package:samids_web_app/src/screen/student/dashboard.dart';

import '../model/faculty_model.dart';
import '../model/student_model.dart';
import '../screen/admin/dashboard.dart';
import '../screen/change_password.dart';
import '../services/DTO/crud_return.dart';
import '../services/config.services.dart';
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
    // _usernameController.text = '0000';

    _usernameController.text = '200001';

    //200005 faculty
    //35526 admin

    _passwordController = TextEditingController();
    // _passwordController.text = 'admin';
    // _passwordController.text = '200005';
    _passwordController.text = '200001';
    // _onLogin(context);
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
  Future<void> _showForgetPasswordDialog(BuildContext context) async {
    String email = '';
    String? securityQuestion = securityQuestions.first;
    final TextEditingController securityAnswerController =
        TextEditingController();

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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  email = value;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                ),
              ),
              const SizedBox(height: 15),
              _dropDownSecurityQuestion(
                securityQuestion,
                (String? value) => securityQuestion = value,
              ),
              const SizedBox(height: 10),
              _inputField(
                securityAnswerController,
                'Answer',
                'Enter your answer',
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (isValidEmail(email)) {
                try {
                  final CRUDReturn result = await ConfigService.forgotPassword(
                    email,
                    securityQuestion!,
                    securityAnswerController.text,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.data),
                      backgroundColor:
                          result.success ? Colors.green : Colors.red,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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

  Widget _inputField(
      TextEditingController controller, String labelText, String hintText,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        hintText: hintText,
      ),
      obscureText: obscureText,
    );
  }

  List<String> securityQuestions = [
    "What is your mother's maiden name?",
    "What was the name of your first pet?",
    "What was your favorite place to visit as a child?",
    "What is the name of your favorite book?",
    "What is the name of the street where you grew up?",
  ];
  Widget _dropDownSecurityQuestion(
      String? currentValue, ValueChanged<String?>? onChanged) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      onChanged: onChanged,
      items: securityQuestions.map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        },
      ).toList(),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Security Question',
      ),

      isExpanded: true, // This will help with fitting long text values
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
                          hintText: 'Enter your password'),
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
                          : const Text("Login"),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () => _showForgetPasswordDialog(context),
                    child: const Text("Forget password?"),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
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
        print('admin');
        AdminController.initialize();
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushNamed(context, AdminDashboard.routeName);
        });
        _setIsloading(false);
        return;
      }
      print('not admin');
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
            child: mobileForum(context),
          );
  }

  Column mobileForum(BuildContext context) {
    return Column(
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => ChangePasswordPage()),
                    // );

                    await _onLogin(context);
                  },
                  child: const Text("Continue"),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () => _showForgetPasswordDialog(context),
                child: const Text("Forget password?"),
              ),
              const SizedBox(
                height: 3,
              ),
              TextButton(
                style:
                    TextButton.styleFrom(backgroundColor: Colors.transparent),
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
    );
  }
}
