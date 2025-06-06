import 'package:flutter/material.dart';

class NyroWalletIcon extends StatelessWidget {
  final double size;

  const NyroWalletIcon({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D), // Matte black background
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'assets/images/nyro_gold_logo.png', // Place your logo here
          width: size * 0.75,
          height: size * 0.75,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
