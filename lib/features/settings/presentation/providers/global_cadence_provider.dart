import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/global_cadence.dart';
import 'settings_flags_provider.dart';

final globalCadenceProvider =
    AsyncNotifierProvider<GlobalCadenceNotifier, GlobalCadenceState>(
      GlobalCadenceNotifier.new,
    );

class GlobalCadenceNotifier extends AsyncNotifier<GlobalCadenceState> {
  static const _storageKey = 'global_cadence';

  @override
  Future<GlobalCadenceState> build() async {
    final repository = ref.read(settingsFlagsRepositoryProvider);
    final stored = await repository.fetchString(_storageKey);
    final selected = stored ?? 'hebdomadaire';
    return GlobalCadenceState(
      options: GlobalCadenceOption.options,
      selectedKey: selected,
    );
  }

  void select(String key) {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(current.select(key));
  }

  Future<bool> persist() async {
    final repository = ref.read(settingsFlagsRepositoryProvider);
    final current = state.value;
    if (current == null) {
      return false;
    }
    try {
      await repository.saveString(_storageKey, current.selectedKey);
      return true;
    } catch (_) {
      return false;
    }
  }
}
