import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final double width;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color.fromRGBO(220, 9, 26, 1),
    this.width = 300,
    this.height = 50,
    this.borderRadius = 10,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoading = onPressed == null;
    
    
    Color disabledColor = Color.fromRGBO(220, 9, 26, 0.5);

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? disabledColor : color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: textStyle ??
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
      ),
    );
  }
}
