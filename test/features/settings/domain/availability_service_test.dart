import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/settings/data/availability_repository.dart';
import 'package:projet_flutter_famille/features/settings/domain/availability_service.dart';
import 'package:projet_flutter_famille/features/settings/domain/availability_window.dart';

class FakeAvailabilityRepository implements AvailabilityRepository {
  List<AvailabilityWindow> stored = const [];

  @override
  Future<List<AvailabilityWindow>> fetchWindows() async => stored;

  @override
  Future<void> saveWindows(List<AvailabilityWindow> windows) async {
    stored = List<AvailabilityWindow>.from(windows);
  }
}

void main() {
  test('AvailabilityService saves and reloads windows', () async {
    final repository = FakeAvailabilityRepository();
    final service = AvailabilityService(repository);
    final windows = [
      const AvailabilityWindow(startMinute: 9 * 60, endMinute: 12 * 60),
      const AvailabilityWindow(startMinute: 14 * 60, endMinute: 18 * 60),
    ];

    await service.saveWindows(windows);
    final loaded = await service.loadWindows();

    expect(loaded.length, 2);
    expect(loaded.first.startMinute, 9 * 60);
    expect(loaded.last.endMinute, 18 * 60);
  });

  test('AvailabilityService rejects overlapping windows', () async {
    final repository = FakeAvailabilityRepository();
    final service = AvailabilityService(repository);
    final windows = [
      const AvailabilityWindow(startMinute: 9 * 60, endMinute: 12 * 60),
      const AvailabilityWindow(startMinute: 11 * 60, endMinute: 13 * 60),
    ];

    await expectLater(service.saveWindows(windows), throwsArgumentError);
  });

  test('AvailabilityService rejects empty windows', () async {
    final repository = FakeAvailabilityRepository();
    final service = AvailabilityService(repository);

    await expectLater(service.saveWindows(const []), throwsArgumentError);
  });
}
