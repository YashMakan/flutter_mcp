import 'package:flutter/material.dart';
import 'package:flutter_mcp_widgets/src/common/gradient_border.dart';

class ApiKeyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? currentApiKey;
  final Function() onSave;
  final Function() onClear;

  const ApiKeyTextField({
    super.key,
    required this.controller,
    required this.currentApiKey,
    required this.onSave,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color primaryTextColor = Colors.white.withOpacity(0.85);
    Color secondaryTextColor = Colors.white.withOpacity(0.6);
    Color containerBgColor = Color(0xFF30302d);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: containerBgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        cursorColor: Colors.white,
        cursorWidth: .8,
        cursorHeight: 16,
        onSubmitted: (_) => onSave(),
        style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w200),
        decoration: InputDecoration(
          hintText: "API KEY",
          hintStyle: TextStyle(color: secondaryTextColor),
          border: InputBorder.none, // Remove default underline
        ),
      ),
    ).gradientBorder();
  }
}
