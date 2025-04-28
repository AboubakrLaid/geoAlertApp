import 'package:flutter/material.dart';

class NoAlertWidget extends StatelessWidget {
  const NoAlertWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 41),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/no-alerts.jpg', height: 251),
          const SizedBox(height: 16),
          const Text('No alerts yet', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color.fromRGBO(37, 37, 37, 1), fontFamily: 'TittilumWeb')),
          const SizedBox(height: 16),
          const Text(
            "Let’s take the time to appreciate and enjoy these peaceful moments.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Color.fromRGBO(37, 37, 37, 1), fontFamily: 'SpaceGrotesk'),
          ),
        ],
      ),
    );
  }
}
