import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/circles_repository.dart';
import '../../domain/circles_service.dart';
import '../../domain/contact_circle.dart';

final circlesRepositoryProvider = Provider<CirclesRepository>((ref) {
  return CirclesRepositoryImpl(AppDatabase.instance);
});

final circlesServiceProvider = Provider<CirclesService>((ref) {
  final repository = ref.read(circlesRepositoryProvider);
  return CirclesService(repository);
});

final selectedCirclesProvider = AsyncNotifierProvider<SelectedCirclesNotifier, List<ContactCircle>>(
  SelectedCirclesNotifier.new,
);

class SelectedCirclesNotifier extends AsyncNotifier<List<ContactCircle>> {
  @override
  Future<List<ContactCircle>> build() {
    final service = ref.read(circlesServiceProvider);
    return service.loadSelectedCircles();
  }

  void toggleCircle(ContactCircle circle) {
    final current = state.value ?? const <ContactCircle>[];
    final updated = List<ContactCircle>.from(current);
    if (updated.contains(circle)) {
      updated.remove(circle);
    } else {
      updated.add(circle);
    }
    state = AsyncData(updated);
  }

  Future<bool> persistSelection() async {
    final service = ref.read(circlesServiceProvider);
    final current = state.value ?? const <ContactCircle>[];
    try {
      await service.saveSelectedCircles(current);
      state = AsyncData(current);
      return true;
    } catch (_) {
      state = AsyncData(current);
      return false;
    }
  }
}
