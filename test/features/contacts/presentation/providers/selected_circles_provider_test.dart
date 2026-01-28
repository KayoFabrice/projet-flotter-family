import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/circles_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/selected_circles_provider.dart';

class FakeCirclesRepository implements CirclesRepository {
  FakeCirclesRepository({List<ContactCircle>? initial})
      : _stored = List<ContactCircle>.from(initial ?? const []);

  List<ContactCircle> _stored;

  @override
  Future<List<ContactCircle>> fetchSelectedCircles() async => List.unmodifiable(_stored);

  @override
  Future<void> saveSelectedCircles(List<ContactCircle> circles) async {
    _stored = List<ContactCircle>.from(circles);
  }
}

void main() {
  test('SelectedCirclesProvider loads empty then persists selection', () async {
    final fakeRepository = FakeCirclesRepository();
    final container = ProviderContainer(
      overrides: [
        circlesRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(selectedCirclesProvider), isA<AsyncLoading<List<ContactCircle>>>());

    final initial = await container.read(selectedCirclesProvider.future);
    expect(initial, isEmpty);

    container.read(selectedCirclesProvider.notifier).toggleCircle(ContactCircle.proches);
    final persisted = await container.read(selectedCirclesProvider.notifier).persistSelection();

    expect(persisted, isTrue);
    expect(fakeRepository.fetchSelectedCircles(), completion([ContactCircle.proches]));
  });

  test('SelectedCirclesProvider reloads stored selection', () async {
    final fakeRepository = FakeCirclesRepository(initial: [ContactCircle.amis]);
    final container = ProviderContainer(
      overrides: [
        circlesRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);

    final loaded = await container.read(selectedCirclesProvider.future);
    expect(loaded, [ContactCircle.amis]);
  });
}
