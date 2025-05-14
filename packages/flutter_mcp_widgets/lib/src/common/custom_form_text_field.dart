// in flutter_mcp_widgets or a common ui folder
// custom_form_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_mcp_widgets/src/common/gradient_border.dart'; // Assuming your gradientBorder extension is here

class CustomFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final void Function(String)? onSubmitted;
  final int maxLines;

  const CustomFormTextField({
    super.key,
    required this.controller,
    required this.labelText, // Changed from hintText to labelText for typical form field
    this.hintText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onSubmitted,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryTextColor = Colors.white.withOpacity(0.85);
    Color labelColor = Colors.white.withOpacity(0.7);
    Color hintColor = Colors.white.withOpacity(0.5);
    Color containerBgColor = const Color(0xFF30302d);
    Color cursorColor = Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          labelText.toUpperCase(), // Consistent with "API KEY"
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w500, // Or Copernicus if it fits
            fontFamily: 'StyreneB', // Or your default form label font
          ),
        ),
        const SizedBox(height: 6.0),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onFieldSubmitted: onSubmitted,
          maxLines: maxLines,
          cursorColor: cursorColor,
          cursorWidth: .8,
          cursorHeight: 16, // Adjust if needed based on text size
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 15, // Slightly smaller than API Key field for form density
            fontWeight: FontWeight.w300, // Lighter for form fields
            fontFamily: 'StyreneB',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w300,
              fontFamily: 'StyreneB',
            ),
            filled: true,
            fillColor: containerBgColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0), // Adjust padding
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none, // No border by default, gradient will be applied
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder( // Keep this to ensure gradient is visible on focus
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none, // The gradientBorder will handle the visual
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
            ),
            errorStyle: TextStyle(fontFamily: 'StyreneB', fontSize: 11, color: Theme.of(context).colorScheme.error.withOpacity(0.9)),
          ),
        ),
      ],
    );
  }
}