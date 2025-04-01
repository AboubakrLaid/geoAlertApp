import 'package:flutter/material.dart';
import 'package:geoalert/presentation/widgets/custom_elevated_button.dart';
import 'package:go_router/go_router.dart';

class EmailConfirmedScreen extends StatelessWidget {
  const EmailConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 32.0, right: 32.0, top: 136.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 251, child: Image(image: AssetImage("assets/images/email-confirmed.jpeg"), fit: BoxFit.fill)),
            Column(
              children: [
                Text("Done", style: TextStyle(color: Color.fromRGBO(25, 25, 25, 1), fontWeight: FontWeight.w700, fontSize: 28, fontFamily: 'Titillium Web')),
                Text("Your email address was successfully verified.", style: TextStyle(color: Color.fromRGBO(25, 25, 25, 1), fontWeight: FontWeight.w300, fontSize: 16)),
              ],
            ),
            SizedBox(height: 24),
            CustomElevatedButton(
              text: "Home",
              onPressed: () {
                GoRouter.of(context).go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
