import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/onboarding_completion_repository.dart';
import '../../../settings/data/settings_flags_repository.dart';
import '../../domain/onboarding_completion.dart';
import '../../domain/onboarding_completion_service.dart';

final onboardingCompletionRepositoryProvider =
    Provider<OnboardingCompletionRepository>((ref) {
  final flagsRepository = SettingsFlagsRepositoryImpl(AppDatabase.instance);
  return OnboardingCompletionRepositoryImpl(flagsRepository);
});

final onboardingCompletionServiceProvider =
    Provider<OnboardingCompletionService>((ref) {
  final repository = ref.read(onboardingCompletionRepositoryProvider);
  return OnboardingCompletionService(repository);
});

final onboardingCompletionProvider =
    AsyncNotifierProvider<OnboardingCompletionNotifier, OnboardingCompletion>(
  OnboardingCompletionNotifier.new,
);

class OnboardingCompletionNotifier extends AsyncNotifier<OnboardingCompletion> {
  @override
  Future<OnboardingCompletion> build() {
    final service = ref.read(onboardingCompletionServiceProvider);
    return service.loadCompletion();
  }

  Future<bool> markComplete() async {
    final service = ref.read(onboardingCompletionServiceProvider);
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      await service.markComplete();
      return const OnboardingCompletion(isComplete: true);
    });
    state = nextState;
    return !nextState.hasError;
  }
}
