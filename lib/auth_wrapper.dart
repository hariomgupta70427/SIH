import 'package:flutter/material.dart';
import 'auth_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Always show auth screen for demo mode
    return AuthScreen();
  }
}