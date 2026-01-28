import 'package:flutter/material.dart';

class CadencePage extends StatelessWidget {
  const CadencePage({super.key});

  static const routeName = '/onboarding/cadence';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Cadence'),
        ),
      ),
    );
  }
}
