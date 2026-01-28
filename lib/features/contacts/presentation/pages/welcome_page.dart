import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/onboarding_step.dart';
import '../providers/onboarding_step_provider.dart';
import 'circles_page.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  static const routeName = '/onboarding/welcome';

  static const _pageBackground = Color(0xFFF6F7F3);
  static const _primaryAction = Color(0xFF4C6FFF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    const _WelcomeIllustration(),
                    const SizedBox(height: 28),
                    Text(
                      'Restez proche de\nceux qui comptent',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Fini les oublis. Votre agenda relationnel\npour garder le lien, sans l'effort.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _primaryAction,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final success = await ref
                              .read(onboardingStepProvider.notifier)
                              .setStep(OnboardingStep.circles);

                          if (!context.mounted) {
                            return;
                          }

                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Impossible d'enregistrer l'etape d'onboarding.",
                                ),
                              ),
                            );
                            return;
                          }

                          await Navigator.of(context).pushNamed(
                            CirclesPage.routeName,
                          );
                        },
                        child: const Text('Commencer'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  static const _assetPath = 'assets/images/onboarding_welcome.png';
  static const _imageBackground = Color(0xFFF6F7F3);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Image.asset(
        _assetPath,
        fit: BoxFit.contain,
        color: _imageBackground,
        colorBlendMode: BlendMode.modulate,
        errorBuilder: (_, __, ___) => const _DefaultIllustration(),
      ),
    );
  }
}

class _DefaultIllustration extends StatelessWidget {
  const _DefaultIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: const [
          _AvatarNode(size: 72, color: Color(0xFFE7ECF7)),
          Positioned(left: 18, top: 20, child: _AvatarNode(size: 36, color: Color(0xFFF0E3E7))),
          Positioned(right: 12, top: 14, child: _AvatarNode(size: 34, color: Color(0xFFE6F1EE))),
          Positioned(left: 6, bottom: 12, child: _AvatarNode(size: 32, color: Color(0xFFEFE7D9))),
          Positioned(right: 8, bottom: 6, child: _AvatarNode(size: 30, color: Color(0xFFE9EEF2))),
          Positioned(left: 62, bottom: 36, child: _AvatarNode(size: 28, color: Color(0xFFF2E6D7))),
          Positioned(right: 70, bottom: 30, child: _AvatarNode(size: 26, color: Color(0xFFE7EDF4))),
        ],
      ),
    );
  }
}

class _AvatarNode extends StatelessWidget {
  const _AvatarNode({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person,
          color: Colors.black54,
          size: size * 0.45,
        ),
      ),
    );
  }
}
