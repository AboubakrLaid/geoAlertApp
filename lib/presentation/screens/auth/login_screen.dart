import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/presentation/providers/auth_provider.dart';
import 'package:geoalert/presentation/widgets/custom_elevated_button.dart';
import 'package:geoalert/presentation/widgets/custom_image.dart';
import 'package:geoalert/presentation/widgets/custom_snack_bar.dart';
import 'package:geoalert/presentation/widgets/custom_text_field.dart';
import 'package:geoalert/routes/routes.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? email;
  const LoginScreen({super.key, this.email});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      await ref.read(authNotifierProvider.notifier).login(email, password).whenComplete(() {
        final bool loginSucceded = !ref.read(authNotifierProvider).hasError;

        if (loginSucceded) {
          GoRouter.of(context).go(Routes.home);
        } else {
          _passwordController.clear();
          final errorMessage = ref.read(authNotifierProvider).error.toString().toLowerCase();
          CustomSnackBar.show(context, message: errorMessage);
          if (errorMessage.contains("please verify your email before logging in".toLowerCase())) {
            GoRouter.of(context).push(Routes.confirmEmail, extra: email);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen(authNotifierProvider, (previous, next) {
    //   if (next.hasError) {
    //     final errorMessage = next.error.toString().toLowerCase();

    //     // _passwordController.clear();
    //     print("I am here");
    //     CustomSnackBar.show(context, message: errorMessage);
    //     if (errorMessage.contains("please verify your email before logging in".toLowerCase())) {
    //       GoRouter.of(context).push(Routes.confirmEmail, extra: _emailController.text.trim());
    //     }
    //   }
    // });

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onLongPress: () => showCustomInputDialog(context),
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 57), child: CustomImage(height: 251, imageUrl: "assets/images/login.jpeg")),
                    ),
                    Column(
                      children: [
                        Text("Welcome Back", style: TextStyle(color: Color.fromRGBO(25, 25, 25, 1), fontWeight: FontWeight.w700, fontSize: 28, fontFamily: 'Titillium Web')),
                        Text("Log in to access your account", style: TextStyle(color: Color.fromRGBO(25, 25, 25, 1), fontWeight: FontWeight.w300, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          initialText: widget.email,
                          hintText: "example@gmail.com",
                          suffixIcon: Icons.email_outlined,
                          validator: (value) => value!.isEmpty ? "Enter email" : null,
                        ),

                        const SizedBox(height: 24),

                        CustomTextField(
                          controller: _passwordController,
                          hintText: "Password",
                          suffixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) => value!.isEmpty ? "Enter password" : null,
                        ),
                      ],
                    ),
                    SizedBox(height: 44),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomElevatedButton(text: "Login", textStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: Colors.white), onPressed: authState.isLoading ? null : _login),

                        SizedBox(height: 24),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "New Member? ",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black, // Default text color
                              ),
                              children: [
                                TextSpan(
                                  text: "Register now",
                                  style: const TextStyle(
                                    color: Color.fromRGBO(220, 9, 26, 1), // Red color for "Register now"
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          ref.read(authNotifierProvider.notifier).resetState();
                                          GoRouter.of(context).go(Routes.register);
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showCustomInputDialog(BuildContext context) {
    final TextEditingController hostController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color.fromRGBO(249, 250, 251, 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 21),
            child: StatefulBuilder(
              builder: (context, setState) {
                // Async init block
                Future.microtask(() async {
                  final savedBaseUrl = await LocalStorage.instance.getBaseUrl();
                  if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
                    final host = savedBaseUrl.replaceAll('http://', '').replaceAll(':7777', '');
                    hostController.text = host;
                    setState(() {}); // Trigger UI update
                  }
                });

                hostController.addListener(() {
                  setState(() {});
                });

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 120, child: Image.asset('assets/images/question-mark.png', fit: BoxFit.fill)),
                      const SizedBox(height: 16),
                      const Text('Set Base URL', style: TextStyle(fontFamily: 'Titillium Web', fontWeight: FontWeight.w700, fontSize: 21,)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: hostController,
                        decoration: InputDecoration(
                          // prefixIcon:
                          //     hostController.text.isNotEmpty
                          //         ? IconButton(
                          //           icon: const Icon(Icons.cancel),
                          //           onPressed: () {
                          //             hostController.clear();
                          //             setState(() {});
                          //           },
                          //         )
                          //         : null,
                          labelText: 'Host',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Cancel button
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w400, fontSize: 18, color: Colors.white)),
                      ),
                      const SizedBox(height: 16),

                      // Save base URL button
                      AbsorbPointer(
                        absorbing: hostController.text.isEmpty,

                        child: ElevatedButton(
                          onPressed: () async {
                            final baseUrl = "http://${hostController.text.trim()}:7777";
                            await LocalStorage.instance.setBaseUrl(baseUrl);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hostController.text.isEmpty ? Colors.grey : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(double.infinity, 0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Save', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w400, fontSize: 18, color: Colors.black)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Clear base URL button
                      ElevatedButton(
                        onPressed: () async {
                          await LocalStorage.instance.setBaseUrl('');
                          hostController.clear();
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Clear Base URL', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w400, fontSize: 18, color: Colors.black)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Reset state on exit
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
