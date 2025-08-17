import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mono/main_page.dart';
import 'package:mono/signup.dart';
import 'package:mono/services/socket_manager.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final _socketManager = SocketManager();


  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  Future<void> _connectToServer() async {
    await _socketManager.connect();
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        if (!_socketManager.isConnected) {
          print('Not connected to server, attempting to reconnect...');
          await _socketManager.connect();

          if (!_socketManager.isConnected) {
            setState(() {
              _errorMessage = "Failed to connect to server. Please check your connection and try again.";
              _isLoading = false;
            });
            return;
          }
        }

        final loginRequest = {
          "action": "log_in",
          "data": {
            "username": _emailController.text.trim(),
            "password": _passwordController.text,
          }
        };

        final responseData = await _socketManager.sendWithResponse(
          jsonEncode(loginRequest),
          timeout: const Duration(seconds: 10),
        );

        if (responseData == null) {
          setState(() {
            _errorMessage = "Server timeout. Please try again.";
            _isLoading = false;
          });
          return;
        }

        final response = jsonDecode(responseData);
        
        if (response['status'] == 200) {
          final token = response['data']['token'];
          final userId = response['data']['user_id'];

          print('Login successful. Token: $token, User ID: $userId');
          
          if (mounted) {
            setState(() {
              _isLoading = false;
            });

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
              (Route<dynamic> route) => false,
            );
          }
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'Login failed';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = "An error occurred: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.inversePrimary,
                  colorScheme.onPrimary,
                ],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Color.fromRGBO(0, 0, 0, 0.2)),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Welcome Back to',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Mono',
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge!.copyWith(fontSize: 80),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),
                    Text(
                      'Login to continue',
                      style: textTheme.titleSmall?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email or Phone Number',
                        prefixIcon: Icon(
                          Icons.person,
                          color: colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your email or phone number';
                        }
                        final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                        final phoneRegex = RegExp(r'^\+?\d{10,15}$');

                        if (emailRegex.hasMatch(value) ||
                            phoneRegex.hasMatch(value)) {
                          return null;
                        }
                        return 'Enter a valid email or phone number';
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.lock_rounded,
                          color: colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Color.fromRGBO(255, 255, 255, 0.1),
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }

                        if (!RegExp(r'[a-z]').hasMatch(value)) {
                          return 'Password must contain at least one lowercase letter';
                        }

                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Password must contain at least one uppercase letter';
                        }

                        if (!RegExp(r'\d').hasMatch(value)) {
                          return 'Password must contain at least one number';
                        }

                        if (_emailController.text.isNotEmpty &&
                            value.toLowerCase().contains(
                              _emailController.text.toLowerCase(),
                            )) {
                          return 'Password should not contain the username';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        )
                        : FilledButton(
                          onPressed: _login,
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            textStyle: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUp(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
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
