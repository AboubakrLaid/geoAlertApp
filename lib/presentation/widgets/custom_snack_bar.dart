import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = const Color.fromRGBO(25, 25, 25, 1),
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 14),
        ),
        backgroundColor: backgroundColor,
        
        
        duration: duration,
      ),
    );
  }
}
