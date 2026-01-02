import 'package:flutter/material.dart';
import '../../auth/presentation/screens/login_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  static const String kOpenLoginArg = 'openLogin';

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _didAutoOpenLogin = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didAutoOpenLogin) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    bool openLogin = false;

    if (args is bool) {
      openLogin = args;
    } else if (args is Map) {
      final map = Map<String, dynamic>.from(args);
      final v = map[StartScreen.kOpenLoginArg];
      if (v is bool) openLogin = v;
    }

    if (!openLogin) return;

    _didAutoOpenLogin = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const LoginScreen(),
      );
    });
  }

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
      child: Image.asset(
        "assets/images/app/start.jpg",
        fit: BoxFit.cover,
        cacheWidth: 540,
        cacheHeight: 1200,
        filterQuality: FilterQuality.medium,
      ),
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
              const _LogoTitle(),
              const SizedBox(height: 20),
              const _WelcomeMessage(),
              const SizedBox(height: 16),
              const _StartButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoTitle extends StatelessWidget {
  const _LogoTitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(22),
        color: const Color(0x33000000),
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
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE0E0E0),
          foregroundColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(34)),
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
