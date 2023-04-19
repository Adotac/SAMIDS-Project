import 'package:flutter/material.dart';
import 'package:samids_web_app/src/auth/controller.dart';

class RegisterPage extends StatefulWidget {
  final AuthViewController controller;
  const RegisterPage({Key? key, required this.controller}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final TextEditingController _userIdController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  String? _securityQuestion1;
  String? _securityQuestion2;

  List<String> securityQuestions = [
    "What is your mother's maiden name?",
    "What was the name of your first pet?",
    "What was your favorite place to visit as a child?",
    "What is the name of your favorite book?",
    "What is the name of the street where you grew up?",
  ];

  @override
  void initState() {
    _userIdController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: registerFormWeb(context),
      ),
    );
  }

  Widget _inputField(
      TextEditingController controller, String labelText, String hintText,
      {bool obscureText = false}) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: labelText,
          hintText: hintText,
        ),
        obscureText: obscureText,
      ),
    );
  }

  Widget _dropDownSecurityQuestion(
      String? currentValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      items: securityQuestions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: 'Security Question',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 72,
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          // Add validation and submission logic here
          // Then navigate back to the login page
          Navigator.pop(context);
        },
        child: const Text("Submit"),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return TextButton(
        child: const Text("Back to login"),
        onPressed: () => {widget.controller.setShowRegister(false)});
  }

  Widget registerFormWeb(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 550,
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _inputField(
                        _userIdController, 'User ID', 'Enter your user ID'),
                    _inputField(_emailController, 'Email', 'Enter your email'),
                    _inputField(
                        _passwordController, 'Password', 'Enter your password',
                        obscureText: true),
                    _inputField(_confirmPasswordController, 'Confirm Password',
                        'Confirm your password',
                        obscureText: true),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: _dropDownSecurityQuestion(_securityQuestion1,
                          (String? newValue) {
                        setState(() {
                          _securityQuestion1 = newValue;
                        });
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: _dropDownSecurityQuestion(_securityQuestion2,
                          (String? newValue) {
                        setState(() {
                          _securityQuestion2 = newValue;
                        });
                      }),
                    ),
                    _submitButton(context),
                    _backButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
