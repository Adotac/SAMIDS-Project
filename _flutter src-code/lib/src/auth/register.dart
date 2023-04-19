import 'package:flutter/material.dart';
import 'package:samids_web_app/src/auth/controller.dart';

class RegisterPage extends StatefulWidget {
  final AuthViewController controller;
  const RegisterPage({Key? key, required this.controller}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  Widget _textFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return SizedBox(
      width: 400,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
          hintText: hint,
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: registerForm(context),
    );
  }

  Widget _inputField(
      TextEditingController controller, String labelText, String hintText,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
          hintText: hintText,
        ),
        obscureText: obscureText,
      ),
    );
  }

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

  Widget _submitButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 72,
      width: 420,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        onPressed: _onSubmit,
        child: const Text('Submit'),
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission logic here, e.g., sending data to the server
      print('Form submitted');
    }
  }

  Widget _backButton(BuildContext context) {
    return TextButton(
        child: const Text("Back to login"),
        onPressed: () => {widget.controller.setShowRegister(false)});
  }

  Widget registerForm(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 550),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: newMethod(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column newMethod(BuildContext context) {
    return Column(
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
        Padding(
          padding: EdgeInsets.all(10),
          child: _textFormField(
            controller: _userIdController,
            label: 'User ID',
            hint: 'Enter your user ID',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a user ID';
              } else if (int.tryParse(value) == null) {
                return 'User ID must be an integer';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: _textFormField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              } else if (!isValidEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: _textFormField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: _textFormField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              } else if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            width: 400, // Adjust this value according to your layout
            child: _dropDownSecurityQuestion(_securityQuestion1,
                (String? newValue) {
              setState(() {
                _securityQuestion1 = newValue;
              });
            }),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: _textFormField(
            controller: TextEditingController(),
            label: 'Answer 1',
            hint: 'Enter your answer to the first security question',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an answer';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            width: 400, // Adjust this value according to your layout
            child: _dropDownSecurityQuestion(_securityQuestion2,
                (String? newValue) {
              setState(() {
                _securityQuestion2 = newValue;
              });
            }),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: _textFormField(
            controller: TextEditingController(),
            label: 'Answer 2',
            hint: 'Enter your answer to the second security question',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an answer';
              }
              return null;
            },
          ),
        ),
        _submitButton(context),
        _backButton(context),
      ],
    );
  }

  bool isValidEmail(String email) {
    RegExp regExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regExp.hasMatch(email);
  }
}
