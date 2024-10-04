import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;
  const CustomButton(
      {super.key,
      required this.text,
      required this.backgroundColor,
      required this.onPressed,
      this.textStyle = const TextStyle(color: Colors.white, fontSize: 18),
      this.padding = const EdgeInsets.symmetric(vertical: 16), CircularProgressIndicator? child, required bool loading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: textStyle,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding
        ),
      ),
    );
  }
}
