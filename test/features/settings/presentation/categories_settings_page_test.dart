import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/settings/data/categories_repository.dart';
import 'package:projet_flutter_famille/features/settings/domain/settings_category.dart';
import 'package:projet_flutter_famille/features/settings/presentation/pages/categories_settings_page.dart';
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
  testWidgets('Categories page adds new category', (tester) async {
    final repository = FakeCategoriesRepository();
    final container = ProviderContainer(
      overrides: [categoriesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CategoriesSettingsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ajouter une categorie'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Cousins');
    final saveButton = find.text('Enregistrer');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Cousins'), findsOneWidget);
  });
}
