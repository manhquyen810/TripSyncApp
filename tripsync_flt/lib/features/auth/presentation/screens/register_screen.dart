import 'package:flutter/material.dart' hide TabBarView;
import 'package:tripsync_flt/features/auth/presentation/screens/login_screen.dart';
import '../widgets/login/login_header.dart';
import '../widgets/login/login_tab_bar.dart';
import '../widgets/login/login_card.dart';
import '../widgets/register/register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool agreeToTerms = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mật khẩu không khớp')));
      return;
    }
    print('Register with: ${emailController.text}');
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

              const SizedBox(height: 34),

              const Padding(
                padding: EdgeInsets.only(left: 24, right: 26),
                child: LoginHeader(),
              ),

              const SizedBox(height: 11),

              LoginCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoginTabBar(
                      isLoginSelected: false,
                      onLoginTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const LoginScreen(),
                        );
                      },
                      onSignupTap: () {
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 24),

                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: SingleChildScrollView(
                        child: RegisterForm(
                          fullNameController: fullNameController,
                          emailController: emailController,
                          passwordController: passwordController,
                          confirmPasswordController: confirmPasswordController,
                          agreeToTerms: agreeToTerms,
                          onTermsChanged: (value) {
                            setState(() {
                              agreeToTerms = value ?? false;
                            });
                          },
                          onRegister: _handleRegister,
                        ),
                      ),
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
