import '../../settings/data/settings_flags_repository.dart';

abstract class OnboardingCompletionRepository {
  Future<bool> fetchIsComplete();
  Future<void> setComplete(bool value);
}

class OnboardingCompletionRepositoryImpl implements OnboardingCompletionRepository {
  OnboardingCompletionRepositoryImpl(this._flagsRepository);

  final SettingsFlagsRepository _flagsRepository;

  static const _completionKey = 'onboarding_complete';

  @override
  Future<bool> fetchIsComplete() async {
    try {
      return await _flagsRepository.fetchBool(_completionKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setComplete(bool value) async {
    await _flagsRepository.saveBool(_completionKey, value);
  }
}
