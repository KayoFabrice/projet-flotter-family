import 'package:flutter/material.dart';

class CirclesPage extends StatelessWidget {
  const CirclesPage({super.key});

  static const routeName = '/onboarding/circles';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Selection des cercles'),
        ),
      ),
    );
  }
}
