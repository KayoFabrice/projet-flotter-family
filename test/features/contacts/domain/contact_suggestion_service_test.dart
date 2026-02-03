import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_action_types.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_entry.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_suggestion_service.dart';

void main() {
  test('ContactSuggestionService uses latest history entry', () {
    final service = ContactSuggestionService();
    final contact = Contact(
      id: '1',
      displayName: 'Maman',
      circle: ContactCircle.proches,
      createdAt: DateTime(2026, 1, 1).toUtc().toIso8601String(),
    );
    final history = [
      ContactHistoryEntry(
        id: 1,
        contactId: '1',
        actionType: 'message',
        occurredAt: DateTime(2026, 1, 5).toUtc().toIso8601String(),
      ),
      ContactHistoryEntry(
        id: 2,
        contactId: '1',
        actionType: 'call',
        occurredAt: DateTime(2026, 1, 10).toUtc().toIso8601String(),
      ),
    ];

    final next = service.computeNextSuggestedAt(
      contact: contact,
      cadenceDays: 7,
      history: history,
    );

    expect(next, DateTime(2026, 1, 17).toUtc());
  });

  test('ContactSuggestionService falls back to createdAt when history empty', () {
    final service = ContactSuggestionService();
    final createdAt = DateTime(2026, 1, 3).toUtc();
    final contact = Contact(
      id: '1',
      displayName: 'Papa',
      circle: ContactCircle.proches,
      createdAt: createdAt.toIso8601String(),
    );

    final next = service.computeNextSuggestedAt(
      contact: contact,
      cadenceDays: 14,
      history: const [],
    );

    expect(next, createdAt.add(const Duration(days: 14)));
  });

  test('ContactSuggestionService ignores future history entries', () {
    final now = DateTime(2026, 1, 10).toUtc();
    final service = ContactSuggestionService(clock: () => now);
    final contact = Contact(
      id: '1',
      displayName: 'Tonton',
      circle: ContactCircle.amis,
      createdAt: DateTime(2026, 1, 1).toUtc().toIso8601String(),
    );
    final history = [
      ContactHistoryEntry(
        id: 1,
        contactId: '1',
        actionType: 'message',
        occurredAt: now.add(const Duration(days: 3)).toIso8601String(),
      ),
      ContactHistoryEntry(
        id: 2,
        contactId: '1',
        actionType: 'call',
        occurredAt: now.subtract(const Duration(days: 2)).toIso8601String(),
      ),
    ];

    final next = service.computeNextSuggestedAt(
      contact: contact,
      cadenceDays: 7,
      history: history,
    );

    expect(next, now.subtract(const Duration(days: 2)).add(const Duration(days: 7)));
  });

  test('ContactSuggestionService computes next suggestion using cadence map', () {
    final service = ContactSuggestionService();
    final baseDate = DateTime(2026, 1, 5).toUtc();
    final contacts = [
      Contact(
        id: '1',
        displayName: 'Alice',
        circle: ContactCircle.proches,
        createdAt: DateTime(2026, 1, 1).toUtc().toIso8601String(),
      ),
      Contact(
        id: '2',
        displayName: 'Bruno',
        circle: ContactCircle.eloignes,
        createdAt: DateTime(2026, 1, 1).toUtc().toIso8601String(),
      ),
    ];
    final histories = {
      '1': [
        ContactHistoryEntry(
          id: 1,
          contactId: '1',
          actionType: 'message',
          occurredAt: baseDate.toIso8601String(),
        ),
      ],
      '2': [
        ContactHistoryEntry(
          id: 2,
          contactId: '2',
          actionType: 'call',
          occurredAt: baseDate.toIso8601String(),
        ),
      ],
    };

    final suggestion = service.computeNextSuggestion(
      contacts: contacts,
      cadences: {
        ContactCircle.proches: 7,
        ContactCircle.eloignes: 30,
      },
      histories: histories,
    );

    expect(suggestion, isNotNull);
    expect(suggestion!.contact.id, '1');
    expect(suggestion.nextSuggestedAt, baseDate.add(const Duration(days: 7)));
  });

  test('ContactSuggestionService ignore les tentatives pour la cadence', () {
    final service = ContactSuggestionService();
    final contact = Contact(
      id: '1',
      displayName: 'Maman',
      circle: ContactCircle.proches,
      createdAt: DateTime(2026, 1, 1).toUtc().toIso8601String(),
    );
    final history = [
      ContactHistoryEntry(
        id: 1,
        contactId: '1',
        actionType: ContactActionTypes.writeAttempt,
        occurredAt: DateTime(2026, 1, 10).toUtc().toIso8601String(),
      ),
      ContactHistoryEntry(
        id: 2,
        contactId: '1',
        actionType: 'message',
        occurredAt: DateTime(2026, 1, 5).toUtc().toIso8601String(),
      ),
    ];

    final next = service.computeNextSuggestedAt(
      contact: contact,
      cadenceDays: 7,
      history: history,
    );

    expect(next, DateTime(2026, 1, 12).toUtc());
  });
}
