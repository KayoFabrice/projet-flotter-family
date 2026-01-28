import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/onboarding_repository.dart';
import '../../domain/onboarding_service.dart';
import '../../domain/onboarding_step.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(AppDatabase.instance);
});

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  final repository = ref.read(onboardingRepositoryProvider);
  return OnboardingService(repository);
});

final onboardingStepProvider = AsyncNotifierProvider<OnboardingStepNotifier, OnboardingStep>(
  OnboardingStepNotifier.new,
);

class OnboardingStepNotifier extends AsyncNotifier<OnboardingStep> {
  @override
  Future<OnboardingStep> build() {
    final service = ref.read(onboardingServiceProvider);
    return service.loadCurrentStep();
  }

  Future<bool> setStep(OnboardingStep step) async {
    final service = ref.read(onboardingServiceProvider);
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      await service.saveCurrentStep(step);
      return step;
    });
    state = nextState;
    return !nextState.hasError;
  }
}
