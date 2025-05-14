import 'package:flutter/material.dart';
import 'package:flutter_mcp_widgets/src/common/gradient_border.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconButton extends StatelessWidget {
  final String icon;
  final Color? color;
  final bool showBorder;
  final VoidCallback onTap;

  const CustomIconButton(
      {super.key,
      required this.icon,
      this.color,
      this.showBorder = true,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: color ?? Color(0xFF30302d),
            borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.all(8),
        child: SvgPicture.asset(
          icon,
          width: 16,
        ),
      ).gradientBorder(borderWidth: .2, enable: showBorder),
    );
  }
}
