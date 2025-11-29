import 'dart:math';

import 'package:flutter/material.dart';
import '../../services/size_config.dart';

class DemoShape extends StatefulWidget {
  const DemoShape({Key? key}) : super(key: key);

  @override
  State<DemoShape> createState() => _DemoShapeState();
}

class _DemoShapeState extends State<DemoShape> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: ClipPath(
        clipper: HeaderClipper(avatarRadius: 2),
        child: Container(
          height: h(30),
          color: Colors.yellow,
        ),
        // child: CustomPaint(
        //   size: Size.fromHeight(400.0),
        //   painter: HeaderPainter(color: Colors.red, avatarRadius: 20),
        // ),
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  HeaderClipper({@required this.avatarRadius});

  final avatarRadius;

  @override
  getClip(Size size) {
    final path = Path()
      ..lineTo(0.0, size.height - 100)
      ..quadraticBezierTo(size.width / 4, (size.height - avatarRadius), size.width / 2, (size.height - avatarRadius))
      ..quadraticBezierTo(size.width - (size.width / 4), (size.height - avatarRadius), size.width, size.height - 100)
      ..lineTo(size.width - 100, 0.0)
      ..quadraticBezierTo(size.width / 4, (size.height - avatarRadius), size.width / 2, (size.height - avatarRadius))
      ..quadraticBezierTo(size.width - (size.width / 4), (size.height - avatarRadius), size.width, size.height - 100)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}

class HeaderPainter extends CustomPainter {
  HeaderPainter({required this.color, required this.avatarRadius});

  final Color color;
  final double avatarRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final shapeBounds = Rect.fromLTRB(0, 0, size.width, size.height - avatarRadius);
    final centerAvatar = Offset(shapeBounds.center.dx, shapeBounds.bottom);
    final avatarBounds = Rect.fromCircle(center: centerAvatar, radius: avatarRadius).inflate(3);
    _drawBackground(canvas, shapeBounds, avatarBounds);
  }

  @override
  bool shouldRepaint(HeaderPainter oldDelegate) {
    return color != oldDelegate.color;
  }

  void _drawBackground(Canvas canvas, Rect shapeBounds, Rect avatarBounds) {
    final paint = Paint()..color = color;

    final backgroundPath = Path()
      ..moveTo(shapeBounds.left, shapeBounds.top)
      ..lineTo(shapeBounds.bottomLeft.dx, shapeBounds.bottomLeft.dy)
      ..arcTo(avatarBounds, -pi, pi, false)
      ..lineTo(shapeBounds.bottomRight.dx, shapeBounds.bottomRight.dy)
      ..lineTo(shapeBounds.topRight.dx, shapeBounds.topRight.dy)
      ..lineTo(0.0, shapeBounds.height - 100)
      ..quadraticBezierTo(shapeBounds.width / 4, shapeBounds.height, shapeBounds.width / 2, shapeBounds.height)
      ..quadraticBezierTo(shapeBounds.width - shapeBounds.width / 4, shapeBounds.height, shapeBounds.width, shapeBounds.height - 100)
      ..lineTo(shapeBounds.width, 0.0)
      ..close();

    canvas.drawPath(backgroundPath, paint);
  }
}
