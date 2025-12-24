import 'package:flutter/material.dart';
import '../../auth/presentation/screens/login_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [const _BackgroundImage(), const _ContentOverlay()],
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset("assets/images/app/start.jpg", fit: BoxFit.cover),
    );
  }
}

class _ContentOverlay extends StatelessWidget {
  const _ContentOverlay();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LogoTitle(),
              const SizedBox(height: 20),
              _WelcomeMessage(),
              const SizedBox(height: 16),
              _StartButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(22),
        color: Colors.black.withOpacity(0.2),
      ),
      child: const Text(
        "TripSync",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * 0.84,
      child: const Text(
        "Chào mừng bạn đến với TripSync! Cùng TripSync tạo nên những kỷ niệm đáng nhớ. Hãy bắt đầu lên kế hoạch cho chuyến phiêu lưu hoàn hảo.",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
          color: Colors.white,
          height: 1.43,
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey[100],
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(34),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
          ),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const LoginScreen(),
          );
        },
        child: const Text("Bắt đầu"),
      ),
    );
  }
}
