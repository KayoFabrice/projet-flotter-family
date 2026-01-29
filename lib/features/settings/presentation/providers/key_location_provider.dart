import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/key_location_repository.dart';
import '../../domain/key_location.dart';
import '../../domain/key_location_service.dart';

final keyLocationRepositoryProvider = Provider<KeyLocationRepository>((ref) {
  return KeyLocationRepositoryImpl(AppDatabase.instance);
});

final keyLocationServiceProvider = Provider<KeyLocationService>((ref) {
  final repository = ref.read(keyLocationRepositoryProvider);
  return KeyLocationService(repository);
});

final keyLocationProvider =
    AsyncNotifierProvider<KeyLocationNotifier, KeyLocation>(KeyLocationNotifier.new);

class KeyLocationNotifier extends AsyncNotifier<KeyLocation> {
  @override
  Future<KeyLocation> build() async {
    final service = ref.read(keyLocationServiceProvider);
    return service.loadKeyLocation();
  }

  Future<void> updateLabel(String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Label vide.');
    }
    final service = ref.read(keyLocationServiceProvider);
    final next = KeyLocation(label: trimmed);
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      await service.saveKeyLocation(next);
      return next;
    });
    state = nextState;
  }
}
