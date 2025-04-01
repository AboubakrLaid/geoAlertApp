import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final String? initialText; // Optional initial text

  CustomTextField({super.key, required this.controller, required this.hintText, this.suffixIcon, this.obscureText = false, this.validator, this.initialText}) {
    if (initialText != null) {
      controller.text = initialText!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color.fromRGBO(0, 0, 0, 0.4)),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        suffixIconColor: const Color.fromRGBO(0, 0, 0, 0.3),
        filled: true,
        fillColor: const Color.fromRGBO(196, 196, 196, 0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      validator: validator,
    );
  }
}
