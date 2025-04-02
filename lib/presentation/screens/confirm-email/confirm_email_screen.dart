import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/presentation/providers/email_verification_provider.dart';
import 'package:geoalert/presentation/widgets/custom_elevated_button.dart';
import 'package:geoalert/presentation/widgets/custom_snack_bar.dart';
import 'package:geoalert/presentation/widgets/otp_text_field.dart';
import 'package:geoalert/routes/routes.dart';
import 'package:go_router/go_router.dart';

class ConfirmEmailScreen extends ConsumerStatefulWidget {
  final String email;

  const ConfirmEmailScreen({super.key, required this.email});

  @override
  ConsumerState<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends ConsumerState<ConfirmEmailScreen> {
  String _otpCode = "";
  int _resendCooldown = 0; // Cooldown timer in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown(); // Start cooldown when screen loads
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _resendCooldown = 45;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _verifyEmail() async {
    if (_otpCode.length != 6) {
      CustomSnackBar.show(context, message: "Please enter a valid 6-digit code");
      return;
    }

    final emailVerificationNotifier = ref.read(emailVerificationProvider.notifier);
    // setState(() => _isLoading = true);

    await emailVerificationNotifier.verifyEmail(email: widget.email, code: _otpCode);
    if (!ref.read(emailVerificationProvider).hasError) {
      GoRouter.of(context).push(Routes.login, extra: widget.email);
    }
  }

  void _resendCode() async {
    if (_resendCooldown > 0) return; // Prevent multiple taps

    final emailVerificationNotifier = ref.read(emailVerificationProvider.notifier);
    // setState(() => _isLoading = true);

    try {
      await emailVerificationNotifier.resendCode(email: widget.email);
      if (mounted) {
        CustomSnackBar.show(context, message: "New verification code sent.");
      }
      _startCooldown();
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(emailVerificationProvider, (previous, next) {
      if (next.hasError) {
        final errorMessage = next.error.toString().toLowerCase();

        CustomSnackBar.show(context, message: errorMessage);
      }
    });

    final emailVerificationState = ref.watch(emailVerificationProvider);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          label: const Text("Back", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 64, 16, 0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Almost There", style: TextStyle(color: Color.fromRGBO(25, 25, 25, 1), fontWeight: FontWeight.w700, fontSize: 28, fontFamily: 'Titillium Web')),
                  const SizedBox(height: 24),
                  Text.rich(
                    TextSpan(
                      text: "Please enter the 6-digit code sent to your email ",
                      style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w300, fontSize: 16, height: 1.0, letterSpacing: 0),
                      children: [
                        TextSpan(text: widget.email, style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w700, fontSize: 16, height: 1.0, letterSpacing: 0)),
                        const TextSpan(text: " for verification.", style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w300, fontSize: 16, height: 1.0, letterSpacing: 0)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  OtpTextField(
                    onChanged: (code) {
                      setState(() {
                        _otpCode = code;
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                  CustomElevatedButton(
                    text: "Verify",
                    textStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: Colors.white),
                    onPressed: emailVerificationState.isLoading ? null : _verifyEmail,
                  ),
                  const SizedBox(height: 48),
                  RichText(
                    text: TextSpan(
                      text: "Didn’t receive any code? ",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Resend code",
                          style: TextStyle(
                            color:
                                _resendCooldown > 0
                                    ? Colors
                                        .grey
                                        .shade400 // Disabled color
                                    : const Color.fromRGBO(220, 9, 26, 1), // Active color
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: _resendCooldown > 0 ? null : (TapGestureRecognizer()..onTap = _resendCode),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_resendCooldown > 0) Text("Resend available in $_resendCooldown s", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
