import 'package:flutter/material.dart';

class FirstContactsPage extends StatelessWidget {
  const FirstContactsPage({super.key});

  static const routeName = '/onboarding/first-contacts';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Premiers contacts'),
        ),
      ),
    );
  }
}
