import 'package:flutter/material.dart';
import '../widgets/login/login_header.dart';
import '../widgets/login/login_tab_bar.dart';
import '../widgets/login/login_form.dart';
import '../widgets/login/login_card.dart';
import 'register_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoginSelected = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _handleForgotPassword() {
    print('Forgot password');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 26.5, top: 45.5),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 15,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 47),

              const Padding(
                padding: EdgeInsets.only(left: 24, right: 26),
                child: LoginHeader(),
              ),

              const Spacer(),

              LoginCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoginTabBar(
                      isLoginSelected: isLoginSelected,
                      onLoginTap: () {
                        setState(() {
                          isLoginSelected = true;
                        });
                      },
                      onSignupTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const RegisterScreen(),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    LoginForm(
                      emailController: emailController,
                      passwordController: passwordController,
                      onForgotPassword: _handleForgotPassword,
                      onLogin: _handleLogin,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
