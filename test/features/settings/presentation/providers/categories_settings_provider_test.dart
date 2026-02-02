import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/settings/data/categories_repository.dart';
import 'package:projet_flutter_famille/features/settings/domain/settings_category.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/categories_settings_provider.dart';

class FakeCategoriesRepository implements CategoriesRepository {
  FakeCategoriesRepository({List<SettingsCategory>? initial})
    : _stored = initial ?? const [];

  List<SettingsCategory> _stored;

  @override
  Future<List<SettingsCategory>> fetchCategories() async => _stored;

  @override
  Future<void> saveCategories(List<SettingsCategory> categories) async {
    _stored = List<SettingsCategory>.from(categories);
  }
}

void main() {
  test('CategoriesSettingsProvider toggles and adds category', () async {
    final repository = FakeCategoriesRepository();
    final container = ProviderContainer(
      overrides: [categoriesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final initial = await container.read(categoriesSettingsProvider.future);
    expect(initial.length, 3);

    final notifier = container.read(categoriesSettingsProvider.notifier);
    notifier.toggle(initial.first.id);
    notifier.addCategory('Cousins');
    final saved = await notifier.persist();

    expect(saved, isTrue);
    expect(repository._stored.length, 4);
  });
}
