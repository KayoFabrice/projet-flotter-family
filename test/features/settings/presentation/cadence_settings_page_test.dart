import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/settings/data/settings_flags_repository.dart';
import 'package:projet_flutter_famille/features/settings/presentation/pages/cadence_settings_page.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/global_cadence_provider.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/settings_flags_provider.dart';

class FakeSettingsFlagsRepository implements SettingsFlagsRepository {
  final Map<String, bool> boolStorage = {};
  final Map<String, String> stringStorage = {};

  @override
  Future<bool?> fetchBool(String key) async => boolStorage[key];

  @override
  Future<void> saveBool(String key, bool value) async {
    boolStorage[key] = value;
  }

  @override
  Future<String?> fetchString(String key) async => stringStorage[key];

  @override
  Future<void> saveString(String key, String value) async {
    stringStorage[key] = value;
  }
}

void main() {
  testWidgets('Cadence globale updates selection', (tester) async {
    final repository = FakeSettingsFlagsRepository();
    repository.stringStorage['global_cadence'] = 'hebdomadaire';
    final container = ProviderContainer(
      overrides: [
        settingsFlagsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CadenceSettingsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hebdomadaire'), findsOneWidget);

    await tester.tap(find.text('Mensuel'));
    await tester.pumpAndSettle();

    final state = container.read(globalCadenceProvider).value;
    expect(state?.selectedKey, 'mensuel');
  });
}
