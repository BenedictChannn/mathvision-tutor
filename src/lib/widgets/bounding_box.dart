import 'package:flutter/material.dart';

/// BoundingBox
/// ------------
/// A reusable overlay that draws a rounded-rect frame to guide users when
/// capturing a math problem. It is designed to sit on top of a camera preview
/// using a Stack.
///
class BoundingBox extends StatelessWidget {
  const BoundingBox({
    super.key,
    this.borderColor = const Color(0xFF9BE368), // Accent Lime from palette
    this.borderWidth = 4,
    this.cornerRadius = 12,
    this.horizontalMargin = 24,
    this.verticalMargin = 72,
  });

  /// Color of the bounding box border.
  final Color borderColor;

  /// Stroke width of the border.
  final double borderWidth;

  /// Corner radius for the rounded rectangle.
  final double cornerRadius;

  /// Horizontal margin from the left/right edges of the preview.
  final double horizontalMargin;

  /// Vertical margin from the top/bottom edges of the preview.
  final double verticalMargin;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        // Ensure overlay does not intercept touch events.
        child: CustomPaint(
          painter: _BoundingBoxPainter(
            borderColor: borderColor,
            borderWidth: borderWidth,
            cornerRadius: cornerRadius,
            horizontalMargin: horizontalMargin,
            verticalMargin: verticalMargin,
          ),
          size: Size.infinite,
        ),
      );
}

class _BoundingBoxPainter extends CustomPainter {
  _BoundingBoxPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.cornerRadius,
    required this.horizontalMargin,
    required this.verticalMargin,
  });

  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;
  final double horizontalMargin;
  final double verticalMargin;

  Paint get _paint => Paint()
    ..color = borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate rect inside the given margins.
    final rect = Rect.fromLTWH(
      horizontalMargin,
      verticalMargin,
      size.width - horizontalMargin * 2,
      size.height - verticalMargin * 2,
    );

    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));

    canvas.drawRRect(rRect, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
