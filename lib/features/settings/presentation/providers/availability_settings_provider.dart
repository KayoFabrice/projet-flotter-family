import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/availability_settings_repository.dart';
import '../../domain/availability_service.dart';
import '../../domain/availability_settings.dart';
import '../../domain/availability_window.dart';
import '../../../contacts/domain/contact_circle.dart';

final availabilitySettingsRepositoryProvider =
    Provider<AvailabilitySettingsRepository>((ref) {
      return AvailabilitySettingsRepositoryImpl(AppDatabase.instance);
    });

final availabilitySettingsServiceProvider =
    Provider<AvailabilitySettingsService>((ref) {
      final repository = ref.read(availabilitySettingsRepositoryProvider);
      return AvailabilitySettingsService(repository);
    });

final availabilitySettingsProvider =
    AsyncNotifierProvider<AvailabilitySettingsNotifier, AvailabilitySettings>(
      AvailabilitySettingsNotifier.new,
    );

class AvailabilitySettingsNotifier extends AsyncNotifier<AvailabilitySettings> {
  @override
  Future<AvailabilitySettings> build() async {
    final service = ref.read(availabilitySettingsServiceProvider);
    return service.loadSettings();
  }

  void addWindow(AvailabilityWindow window) {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(windows: [...current.windows, window]));
  }

  void updateWindow(int index, AvailabilityWindow window) {
    final current = state.value;
    if (current == null || index < 0 || index >= current.windows.length) {
      return;
    }
    final updated = [...current.windows];
    updated[index] = window;
    state = AsyncData(current.copyWith(windows: updated));
  }

  void removeWindow(int index) {
    final current = state.value;
    if (current == null || index < 0 || index >= current.windows.length) {
      return;
    }
    final updated = [...current.windows]..removeAt(index);
    state = AsyncData(current.copyWith(windows: updated));
  }

  void toggleCategory(ContactCircle circle, bool enabled) {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(current.toggleCategory(circle, enabled));
  }

  Future<bool> persist() async {
    final service = ref.read(availabilitySettingsServiceProvider);
    final current = state.value;
    if (current == null) {
      return false;
    }
    state = const AsyncLoading();
    try {
      await service.saveSettings(current);
      state = AsyncData(current);
      return true;
    } catch (_) {
      state = AsyncData(current);
      return false;
    }
  }
}
