import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/categories_repository.dart';
import '../../domain/settings_category.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepositoryImpl(AppDatabase.instance);
});

final categoriesSettingsProvider =
    AsyncNotifierProvider<CategoriesSettingsNotifier, List<SettingsCategory>>(
      CategoriesSettingsNotifier.new,
    );

class CategoriesSettingsNotifier extends AsyncNotifier<List<SettingsCategory>> {
  @override
  Future<List<SettingsCategory>> build() async {
    final repository = ref.read(categoriesRepositoryProvider);
    final categories = await repository.fetchCategories();
    return categories.isEmpty ? SettingsCategory.defaults : categories;
  }

  void toggle(String id) {
    final current = state.value ?? const <SettingsCategory>[];
    final updated = current
        .map(
          (category) => category.id == id
              ? category.copyWith(isActive: !category.isActive)
              : category,
        )
        .toList();
    state = AsyncData(updated);
  }

  void addCategory(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final current = state.value ?? const <SettingsCategory>[];
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final updated = [
      ...current,
      SettingsCategory(id: id, name: trimmed, description: '', isActive: true),
    ];
    state = AsyncData(updated);
  }

  Future<bool> persist() async {
    final repository = ref.read(categoriesRepositoryProvider);
    final current = state.value;
    if (current == null) {
      return false;
    }
    try {
      await repository.saveCategories(current);
      return true;
    } catch (_) {
      return false;
    }
  }
}
