import 'package:flutter/material.dart';

class TextfieldCustom extends StatefulWidget {
  final TextEditingController controller;
  final bool obscureText;
  final bool showPasswordtoggle;
  final String hintText;
  final Color textColor;
  final Color hintTextColor;
  final Color cursorColor;
  final Color iconColor;
  final Color fillColor;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  const TextfieldCustom(
      {super.key,
      required this.controller,
      required this.obscureText,
      this.showPasswordtoggle = false,
      this.hintText = '',
      this.textColor = Colors.black,
      this.hintTextColor = Colors.black,
      this.cursorColor = Colors.black,
      this.iconColor = Colors.blue,
      this.fillColor = const Color(0xFFF4F6F9),
      this.keyboardType = TextInputType.text,
      this.onChanged});

  @override
  State<TextfieldCustom> createState() => _TextfieldCustomState();
}

class _TextfieldCustomState extends State<TextfieldCustom> {
  bool _obscureText = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.transparent,
          )
        ),
        filled: true,
        fillColor: widget.fillColor,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: widget.hintTextColor),
        suffixIcon: widget.showPasswordtoggle
          ?IconButton(onPressed: (){
            setState(() {
              _obscureText = !_obscureText;
            });
          }, icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off)) : null
      ),
      obscureText: widget.showPasswordtoggle ? _obscureText : widget.obscureText,
      style: TextStyle(color: widget.textColor),
      cursorColor: widget.cursorColor,
      onChanged: widget.onChanged,
    );
  }
}
