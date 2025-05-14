import 'package:flutter/material.dart';

extension GradientBorder on Container {
  Widget gradientBorder({Gradient? gradient, double borderWidth = 0.5, bool enable = true}) {
    if(!enable) return this;
    return Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        gradient:
            gradient ?? LinearGradient(colors: [Colors.white54, Colors.white38]),
        borderRadius: (decoration as BoxDecoration?)?.borderRadius,
      ),
      child: this,
    );
  }
}
