import 'package:flutter/material.dart';
import 'login_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  static const String routeName = '/get-started';

  @override
  Widget build(BuildContext context) {
    // Colors used in this design
    const Color matteBlack = Color(0xFF0D0D0D);
    const Color darkPanel = Color(0xFF1A1A1A);
    const Color royalGold = Color(0xFFF6C141);

    return Scaffold(
      backgroundColor: matteBlack,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ——— Logo Container ———
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: darkPanel,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/nyro_gold_logo.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ——— App Title ———
              const Text(
                "NyroWallet",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: royalGold,
                ),
              ),

              const SizedBox(height: 12),

              // ——— Subtitle/Tagline ———
              const Text(
                "Modern Card Management\nMade Easy",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: royalGold, height: 1.5),
              ),

              const SizedBox(height: 48),

              // ——— Get Started Button ———
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: royalGold,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 10,
                  shadowColor: Colors.black.withOpacity(0.5),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
