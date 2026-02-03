import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/contact_history_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_action_types.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_entry.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_service.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_write_action_service.dart';

class _FakeHistoryRepository implements ContactHistoryRepository {
  final entries = <ContactHistoryEntry>[];

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
    entries.add(
      ContactHistoryEntry(
        id: entries.length + 1,
        contactId: contactId,
        actionType: actionType,
        occurredAt: occurredAt,
      ),
    );
    return entries.length;
  }
}

class _FakeLauncher implements ContactActionLauncher {
  _FakeLauncher({required this.canLaunchResult, required this.launchResult});

  final bool canLaunchResult;
  final bool launchResult;

  @override
  Future<bool> canLaunch(Uri uri) async => canLaunchResult;

  @override
  Future<bool> launch(Uri uri) async => launchResult;
}

void main() {
  test('ContactWriteActionService enregistre tentative et succes', () async {
    final now = DateTime(2026, 2, 3, 10, 0, 0);
    final repo = _FakeHistoryRepository();
    final history = ContactHistoryService(
      repository: repo,
      nowUtc: () => now,
    );
    final service = ContactWriteActionService(
      historyService: history,
      launcher: _FakeLauncher(canLaunchResult: true, launchResult: true),
    );

    final result = await service.launchWrite(
      contactId: 'c1',
      uri: Uri.parse('sms:+33612345678'),
    );

    expect(result, ContactWriteOutcome.success);
    expect(repo.entries.length, 2);
    expect(repo.entries[0].actionType, ContactActionTypes.writeAttempt);
    expect(repo.entries[1].actionType, ContactActionTypes.writeSuccess);
  });

  test('ContactWriteActionService enregistre tentative quand indisponible', () async {
    final repo = _FakeHistoryRepository();
    final history = ContactHistoryService(repository: repo);
    final service = ContactWriteActionService(
      historyService: history,
      launcher: _FakeLauncher(canLaunchResult: false, launchResult: false),
    );

    final result = await service.launchWrite(
      contactId: 'c2',
      uri: Uri.parse('mailto:test@example.com'),
    );

    expect(result, ContactWriteOutcome.unavailable);
    expect(repo.entries.length, 1);
    expect(repo.entries.single.actionType, ContactActionTypes.writeAttempt);
  });

  test('ContactWriteActionService enregistre tentative quand launch echoue', () async {
    final repo = _FakeHistoryRepository();
    final history = ContactHistoryService(repository: repo);
    final service = ContactWriteActionService(
      historyService: history,
      launcher: _FakeLauncher(canLaunchResult: true, launchResult: false),
    );

    final result = await service.launchWrite(
      contactId: 'c3',
      uri: Uri.parse('sms:+33612345678'),
    );

    expect(result, ContactWriteOutcome.failed);
    expect(repo.entries.length, 1);
    expect(repo.entries.single.actionType, ContactActionTypes.writeAttempt);
  });
}
