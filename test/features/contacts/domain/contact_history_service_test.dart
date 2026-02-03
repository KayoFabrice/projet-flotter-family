import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/contact_history_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_action_types.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_entry.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_service.dart';

class _FakeHistoryRepository implements ContactHistoryRepository {
  final entries = <Map<String, String>>[];

  @override
  Future<List<ContactHistoryEntry>> fetchRecentHistory(
    String contactId, {
    int limit = 5,
  }) async {
    return const [];
  }

  @override
  Future<int> addHistoryEntry({
    required String contactId,
    required String actionType,
    required String occurredAt,
  }) async {
    entries.add({
      'contactId': contactId,
      'actionType': actionType,
      'occurredAt': occurredAt,
    });
    return entries.length;
  }
}

void main() {
  test('ContactHistoryService enregistre une tentative avec ISO UTC', () async {
    final now = DateTime(2025, 1, 2, 3, 4, 5);
    final repo = _FakeHistoryRepository();
    final service = ContactHistoryService(
      repository: repo,
      nowUtc: () => now,
    );

    await service.recordWriteAttempt(contactId: 'c1');

    expect(repo.entries, hasLength(1));
    final entry = repo.entries.single;
    expect(entry['contactId'], 'c1');
    expect(entry['actionType'], ContactActionTypes.writeAttempt);
    expect(entry['occurredAt'], now.toUtc().toIso8601String());
  });

  test('ContactHistoryService enregistre un succes avec ISO UTC', () async {
    final now = DateTime(2025, 2, 3, 4, 5, 6);
    final repo = _FakeHistoryRepository();
    final service = ContactHistoryService(
      repository: repo,
      nowUtc: () => now,
    );

    await service.recordWriteSuccess(contactId: 'c2');

    expect(repo.entries, hasLength(1));
    final entry = repo.entries.single;
    expect(entry['contactId'], 'c2');
    expect(entry['actionType'], ContactActionTypes.writeSuccess);
    expect(entry['occurredAt'], now.toUtc().toIso8601String());
  });

  test('ContactHistoryService enregistre une tentative d appel avec ISO UTC',
      () async {
    final now = DateTime(2025, 3, 4, 5, 6, 7);
    final repo = _FakeHistoryRepository();
    final service = ContactHistoryService(
      repository: repo,
      nowUtc: () => now,
    );

    await service.recordCallAttempt(contactId: 'c3');

    expect(repo.entries, hasLength(1));
    final entry = repo.entries.single;
    expect(entry['contactId'], 'c3');
    expect(entry['actionType'], ContactActionTypes.callAttempt);
    expect(entry['occurredAt'], now.toUtc().toIso8601String());
  });

  test('ContactHistoryService enregistre un succes d appel avec ISO UTC',
      () async {
    final now = DateTime(2025, 4, 5, 6, 7, 8);
    final repo = _FakeHistoryRepository();
    final service = ContactHistoryService(
      repository: repo,
      nowUtc: () => now,
    );

    await service.recordCallSuccess(contactId: 'c4');

    expect(repo.entries, hasLength(1));
    final entry = repo.entries.single;
    expect(entry['contactId'], 'c4');
    expect(entry['actionType'], ContactActionTypes.callSuccess);
    expect(entry['occurredAt'], now.toUtc().toIso8601String());
  });
}
