import 'package:flutter/material.dart';
import 'package:to_do_list/AuthFunc.dart';

import 'activity.dart'; // Assuming you have authentication functions in this file

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  bool isLogin = false; // Toggle for login/signup
  bool isForget = false; // Toggle for forget password
  String? email = '';
  String? username = '';
  String? password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Authentication'),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: <Widget>[
                    Container(
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://img.freepik.com/premium-vector/creative-elegant-abstract-minimalistic-logo-design-vector-any-brand-company_1287271-56380.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    !isLogin
                        ? const Text(
                      'Login into your account',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey,
                        letterSpacing: 2.0,
                      ),
                    )
                        : const Text(
                      'Sign up into your account',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              !isLogin
                  ? TextFormField(
                key: const ValueKey('username'),
                decoration: const InputDecoration(hintText: "Enter Username"),
                validator: (value) {
                  if (value!.length < 3) {
                    return 'Username is too short';
                  }
                  return null;
                },
                onSaved: (value) {
                  username = value;
                },
              )
                  : Container(),
              // Email field
              TextFormField(
                key: const ValueKey('email'),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || !isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) => email = value,
              ),
              // Password field
              TextFormField(
                obscureText: true,
                key: const ValueKey('password'),
                decoration: const InputDecoration(hintText: "Enter password"),
                validator: (value) {
                  if (value!.length < 6) {
                    return 'The password length is less than 6';
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value;
                },
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // Check if the email is valid
                      bool isEmailFormatValid = isValidEmail(email!);

                      if (isEmailFormatValid) {
                        bool isValid = await validateEmail(email!); // Validate using the ZeroBounce API

                        if (isValid) {
                          if (isLogin) {
                            // Call login for logging in
                            String result = await login(email!, password!);
                            if (result.contains('Logged in successfully')) {
                              // Navigate to the HomePage after a successful login
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Activity()), // Replace HomePage with your second activity
                              );
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result)),
                            );
                          } else {
                            // Call your signup function here
                            String result = await signup(email!, password!);
                            if (result.contains('Logged in successfully')) {
                              // Navigate to the HomePage after a successful login
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Activity()), // Replace HomePage with your second activity
                              );
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result)),
                            );
                          }
                        } else {
                          // Show an error message if email validation fails
                          print('Invalid email provider');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid email provider. Please use a different email.')),
                          );
                        }
                      } else {
                        // Show an error message for invalid email format
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid email format. Please enter a valid email address.')),
                        );
                      }
                    }
                  },
                  child: !isLogin ? const Text('Sign Up') : const Text('Login'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: !isLogin
                    ? const Text('Already Signed up? Login')
                    : const Text('Not Signed up? Sign Up'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    isForget = !isForget;
                  });
                },
                child: !isForget
                    ? const Text('Already Forget')
                    : const Text('Forget'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
