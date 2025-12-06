import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        _page(
          context,
          image: "assets/transfer.png",
          title: "Fast International Transfers",
          subtitle: "Send money across countries instantly & securely.",
        ),
        _page(
          context,
          image: "assets/wallet.png",
          title: "All-in-One Wallet",
          subtitle: "Store funds, convert currencies, and manage transactions.",
        ),
        _page(
          context,
          image: "assets/esim.png",
          title: "eSIM Support",
          subtitle: "Convert your physical SIM to eSIM and stay connected.",
          button: true,
        ),
      ],
    );
  }

  Widget _page(
    BuildContext context, {
    required String image,
    required String title,
    required String subtitle,
    bool button = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(30),
      // color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 260),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          if (button)
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/login"),
              child: const Text("Get Started"),
            ),
        ],
      ),
    );
  }
}
