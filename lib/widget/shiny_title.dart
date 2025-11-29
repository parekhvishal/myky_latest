import 'package:flutter/material.dart';
import 'package:myky_clone/widget/theme.dart';
import 'custom_text.dart';

class ShinyTitle extends StatelessWidget {
  final String text;
  final double? fontSize;
  const ShinyTitle({super.key, required this.text, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        CustomText(
          text,
          fontSize: fontSize,
          fontFamily: fontBold,
          textColor: Colors.white,
          shadows: const [Shadow(offset: Offset(0, 2), blurRadius: 12, color: Colors.white24)],
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ colorPrimary.withOpacity(0.8),
            const Color(0xFF8B5CF6), bodyColor.withOpacity(0.2) ],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(r),
          child: CustomText(text, fontSize: fontSize, fontFamily: fontBold, textColor: Colors.white),
        ),
      ],
    );
  }
}
