import 'package:flutter/material.dart';
import 'package:mono/login.dart';
import 'package:mono/main_page.dart';
import 'package:mono/services/token_storage.dart';
import 'package:mono/services/socket_manager.dart';
import 'dart:convert';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    try {
      final hasToken = await TokenStorage.hasValidToken();
      
      if (hasToken) {
        final socketManager = SocketManager();
        await socketManager.connect();
        
        if (socketManager.isConnected) {
          final tokenData = await TokenStorage.getToken();
          final token = tokenData?['token'];
          
          if (token != null) {
            try {
              final validationRequest = {
                "action": "validate_token",
                "token": token,
                "data": {}
              };
              
              final responseData = await socketManager.sendWithResponse(
                jsonEncode(validationRequest),
                timeout: const Duration(seconds: 5),
              );
              
              if (responseData != null) {
                final response = jsonDecode(responseData);
                if (response['status'] == 200) {
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  }
                  return;
                }
              }
            } catch (e) {
              print('Token validation failed: $e');
            }
          }

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
        } else {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      }
    } catch (e) {
      print('Error during authentication check: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'Mono',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),

            const SizedBox(height: 24),

            Text(
              'Logging in...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
