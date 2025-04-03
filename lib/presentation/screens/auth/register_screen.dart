import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/presentation/providers/auth_provider.dart';
import 'package:geoalert/presentation/widgets/custom_elevated_button.dart';
import 'package:geoalert/presentation/widgets/custom_snack_bar.dart';
import 'package:geoalert/presentation/widgets/custom_text_field.dart';
import 'package:geoalert/routes/routes.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _register() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      await authNotifier
          .register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: email,
            phoneNumber: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
          )
          .whenComplete(() {
            final bool registerSucceded = !ref.read(authNotifierProvider).hasError;
            if (registerSucceded) {
              GoRouter.of(context).go(Routes.confirmEmail, extra: email);
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.hasError) {
        final errorMessage = next.error.toString().toLowerCase();

        CustomSnackBar.show(context, message: errorMessage);
      }
    });
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Column(
                      children: const [
                        Text("Get Started", style: TextStyle(color: Color.fromRGBO(25, 25, 25, 1), fontWeight: FontWeight.w700, fontSize: 28, fontFamily: 'Titillium Web')),
                        SizedBox(height: 5),
                        Text("by creating a free account", style: TextStyle(color: Color.fromRGBO(25, 25, 25, 1), fontWeight: FontWeight.w300, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Form Fields
                    CustomTextField(controller: _firstNameController, hintText: "First Name", validator: (value) => value!.isEmpty ? "Enter your first name" : null),
                    const SizedBox(height: 10),
                    CustomTextField(controller: _lastNameController, hintText: "Last Name", validator: (value) => value!.isEmpty ? "Enter your last name" : null),
                    const SizedBox(height: 10),
                    CustomTextField(controller: _emailController, hintText: "Email", suffixIcon: Icons.email_outlined, validator: (value) => value!.contains("@") ? null : "Enter a valid email"),
                    const SizedBox(height: 10),
                    CustomTextField(controller: _phoneController, hintText: "Phone Number", suffixIcon: Icons.phone, validator: (value) => value!.isEmpty ? "Enter your phone number" : null),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: "Password",
                      suffixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: "Confirm Password",
                      suffixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) => value != _passwordController.text ? "Passwords do not match" : null,
                    ),
                    const SizedBox(height: 10),

                    // Error Message
                    SizedBox(height: 36.0),
                    CustomElevatedButton(
                      text: "Register",
                      textStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: Colors.white),
                      onPressed: authState.isLoading ? null : _register,
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Already a member? ",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Log In",
                              style: const TextStyle(color: Color.fromRGBO(220, 9, 26, 1), fontWeight: FontWeight.bold),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      ref.read(authNotifierProvider.notifier).resetState();
                                      GoRouter.of(context).go(Routes.login);
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
