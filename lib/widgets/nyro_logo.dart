import 'package:flutter/material.dart';

/// A widget that draws a Nyro Wallet icon on a black background,
/// using royal gold / gold shades in the same “geometric overlap” style
/// as the Flutter logo.
class NyroLogo extends StatelessWidget {
  /// The size (width and height) of the square logo. Defaults to 128.
  final double size;

  const NyroLogo({Key? key, this.size = 128}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Constrain into a square of [size] x [size]
    return Container(
      width: size,
      height: size,
      color: Colors.black, // Solid black background
      child: CustomPaint(painter: _NyroLogoPainter()),
    );
  }
}

/// CustomPainter that draws two overlapping “Nyro”‐shaped polygons
/// in two gold tones, left/upper shape in a lighter gold,
/// and right/lower shape in a slightly darker “royal gold.”
class _NyroLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define two Paint objects for light‐gold and dark‐gold:
    final lightGold = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFD700); // bright gold (#FFD700)

    final darkGold = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE3A600); // darker “royal” gold (#E3A600)

    // We will draw two overlapping polygon shapes that mimic the
    // same “two‐tone slanted F” style of the Flutter logo, but forming an “N” shape.

    // Common points are expressed as fractions of the width/height.
    final w = size.width;
    final h = size.height;

    // --------------------------------------------------------------------------------
    // 1) First (lightGold) polygon: a trapezoid that forms the top‐left arm of our “N”
    // --------------------------------------------------------------------------------
    final path1 = Path()
      // Start at the top‐left corner:
      ..moveTo(0.0, 0.0)
      // Draw to a point about 60% across, 0% down (top edge):
      ..lineTo(w * 0.6, 0.0)
      // Then slope diagonally down to about 100% width & 40% height:
      ..lineTo(w, h * 0.4)
      // Then straight down to about 100% width & 60% height:
      ..lineTo(w, h * 0.6)
      // Then back to about 40% width & 60% height:
      ..lineTo(w * 0.4, h * 0.6)
      // From there, slope diagonally back to (0, 20% height):
      ..lineTo(0.0, h * 0.2)
      // And close:
      ..close();

    canvas.drawPath(path1, lightGold);

    // --------------------------------------------------------------------------------
    // 2) Second (darkGold) polygon: a trapezoid that forms the lower‐right leg of our “N”
    // --------------------------------------------------------------------------------
    final path2 = Path()
      // Start at about 40% width & 60% height (this point meets path1’s bottom edge):
      ..moveTo(w * 0.4, h * 0.6)
      // Go down to bottom‐left corner:
      ..lineTo(0.0, h)
      // Then to bottom‐right corner:
      ..lineTo(w, h)
      // Then up to about 100% width & 60% height:
      ..lineTo(w, h * 0.6)
      // Then slope diagonally back to (40% width, 80% height):
      ..lineTo(w * 0.4, h * 0.8)
      // Then to (40% width, 60% height) to close:
      ..close();

    canvas.drawPath(path2, darkGold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No dynamic changes
  }
}
