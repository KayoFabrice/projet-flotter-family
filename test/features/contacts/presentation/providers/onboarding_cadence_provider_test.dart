import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/cadence_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_cadence.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_cadence_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/selected_circles_provider.dart';

class FakeCadenceRepository implements CadenceRepository {
  FakeCadenceRepository({Map<ContactCircle, int>? initial})
      : _stored = Map<ContactCircle, int>.from(initial ?? const {});

  Map<ContactCircle, int> _stored;

  @override
  Future<Map<ContactCircle, int>> fetchCadences() async => Map.unmodifiable(_stored);

  @override
  Future<void> saveCadences(List<ContactCadence> cadences) async {
    _stored = {
      for (final cadence in cadences) cadence.circle: cadence.cadenceDays,
    };
  }
}

class FakeSelectedCirclesNotifier extends SelectedCirclesNotifier {
  @override
  Future<List<ContactCircle>> build() async {
    return [ContactCircle.proches, ContactCircle.eloignes];
  }
}

void main() {
  test('OnboardingCadenceProvider loads defaults and persists updates', () async {
    final fakeRepository = FakeCadenceRepository();
    final container = ProviderContainer(
      overrides: [
        cadenceRepositoryProvider.overrideWithValue(fakeRepository),
        selectedCirclesProvider.overrideWith(FakeSelectedCirclesNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(onboardingCadenceProvider.future);
    expect(
      initial,
      [
        ContactCadence(circle: ContactCircle.proches, cadenceDays: 7),
        ContactCadence(circle: ContactCircle.eloignes, cadenceDays: 30),
      ],
    );

    final notifier = container.read(onboardingCadenceProvider.notifier);
    notifier.updateCadence(ContactCircle.proches, 14);
    final persisted = await notifier.persist();

    expect(persisted, isTrue);
    expect(
      await fakeRepository.fetchCadences(),
      {
        ContactCircle.proches: 14,
        ContactCircle.eloignes: 30,
      },
    );
  });
}
