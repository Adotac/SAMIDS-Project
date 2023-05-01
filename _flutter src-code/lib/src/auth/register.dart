import 'package:flutter/material.dart';
import 'package:samids_web_app/src/auth/controller.dart';

import '../controllers/auth.controller.dart';

class RegisterPage extends StatefulWidget {
  final AuthViewController controller;
  final AuthController authController = AuthController.instance;

  List<String> userTypes = ["Student", "Faculty"];
  Map<String, int> userTypeValues = {"Student": 0, "Faculty": 1};

  RegisterPage({Key? key, required this.controller}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthController get _authController => widget.authController;
  List<String> get _userTypes => widget.userTypes;
  Map<String, int> get _userTypeValues => widget.userTypeValues;

  late final TextEditingController _userIdController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  // String? _securityQuestion1;
  // String? _securityQuestion2;
  int _userType = 0; // 0 for Student (default), 1 for Faculty

  Widget _userTypeDropDown(int currentValue, ValueChanged<int?>? onChanged) {
    return DropdownButtonFormField<int>(
      value: currentValue,
      onChanged: onChanged,
      items: _userTypes.map<DropdownMenuItem<int>>(
        (String value) {
          return DropdownMenuItem<int>(
            value: _userTypeValues[value],
            child: Text(value),
          );
        },
      ).toList(),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'User Type',
      ),
      isExpanded: true,
    );
  }

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

  List<String> securityQuestions = [
    "What is your mother's maiden name?",
    "What was the name of your first pet?",
    "What was your favorite place to visit as a child?",
    "What is the name of your favorite book?",
    "What is the name of the street where you grew up?",
  ];
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

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        bool success = await _authController.register(
          int.parse(_userIdController.text),
          _emailController.text.toLowerCase().trim(),
          _passwordController.text,
          _userType,
        );

        if (success && mounted) {
          widget.controller.setShowRegister(false);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _successDialog("Registration successful", context);
            },
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return _errorDialog(e.toString(), context);
          },
        );
      }
    }
  }

  Widget _successDialog(String message, BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Success'),
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _errorDialog(String message, BuildContext context) {
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
          },
          child: const Text('OK'),
        ),
      ],
    );
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
          padding: const EdgeInsets.all(10),
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
          padding: const EdgeInsets.all(10),
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
          padding: const EdgeInsets.all(10),
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
          padding: const EdgeInsets.all(10),
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
        // Padding(
        //   padding: EdgeInsets.all(10),
        //   child: Container(
        //     width: 400, // Adjust this value according to your layout
        //     child: _dropDownSecurityQuestion(_securityQuestion1,
        //         (String? newValue) {
        //       setState(() {
        //         _securityQuestion1 = newValue;
        //       });
        //     }),
        //   ),
        // ),
        // Padding(
        //   padding: EdgeInsets.all(10),
        //   child: _textFormField(
        //     controller: TextEditingController(),
        //     label: 'Answer 1',
        //     hint: 'Enter your answer to the first security question',
        //     validator: (value) {
        //       if (value == null || value.isEmpty) {
        //         return 'Please enter an answer';
        //       }
        //       return null;
        //     },
        //   ),
        // ),
        // Padding(
        //   padding: EdgeInsets.all(10),
        //   child: Container(
        //     width: 400, // Adjust this value according to your layout
        //     child: _dropDownSecurityQuestion(_securityQuestion2,
        //         (String? newValue) {
        //       setState(() {
        //         _securityQuestion2 = newValue;
        //       });
        //     }),
        //   ),
        // ),
        // Padding(
        //   padding: EdgeInsets.all(10),
        //   child: _textFormField(
        //     controller: TextEditingController(),
        //     label: 'Answer 2',
        //     hint: 'Enter your answer to the second security question',
        //     validator: (value) {
        //       if (value == null || value.isEmpty) {
        //         return 'Please enter an answer';
        //       }
        //       return null;
        //     },
        //   ),
        // ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            width: 400,
            child: _userTypeDropDown(_userType, (int? newValue) {
              setState(() {
                _userType = newValue!;
              });
            }),
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
