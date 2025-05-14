import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuggestionChip extends StatelessWidget {
  final String icon;
  final String label;

  const SuggestionChip(
      {super.key,
      required this.icon,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: SvgPicture.asset(
        icon,
        color: Colors.white.withOpacity(0.85),
        width: 20,
      ),
      label: Text(label,
          style: TextStyle(
              color: Colors.white.withOpacity(0.85), fontSize: 14, fontWeight: FontWeight.w300)),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white.withOpacity(0.85),
          surfaceTintColor: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.white, width: .1)
              // side: BorderSide(color: Colors.white.withOpacity(0.2)) // Optional border
              ),
          elevation: 0),
      onPressed: () {
        // Handle suggestion button press
        print("$label button pressed");
      },
    );
  }
}
