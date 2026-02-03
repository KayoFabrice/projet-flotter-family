import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_entry.dart';
import 'package:projet_flutter_famille/features/reminders/domain/eligibility_result.dart';
import 'package:projet_flutter_famille/features/reminders/domain/suggestion_selector.dart';

void main() {
  test('SuggestionSelector privilegie le retard vs cadence cible', () {
    final selector = SuggestionSelector();
    final now = DateTime.utc(2026, 1, 10, 12);

    final contactA = Contact(
      id: 'a',
      displayName: 'Alice',
      circle: ContactCircle.proches,
      createdAt: DateTime.utc(2025, 12, 1).toIso8601String(),
    );
    final contactB = Contact(
      id: 'b',
      displayName: 'Benoit',
      circle: ContactCircle.eloignes,
      createdAt: DateTime.utc(2025, 12, 1).toIso8601String(),
    );

    final histories = {
      'a': [
        ContactHistoryEntry(
          id: 1,
          contactId: 'a',
          actionType: 'call',
          occurredAt: DateTime.utc(2026, 1, 1).toIso8601String(),
        ),
      ],
      'b': [
        ContactHistoryEntry(
          id: 2,
          contactId: 'b',
          actionType: 'call',
          occurredAt: DateTime.utc(2026, 1, 5).toIso8601String(),
        ),
      ],
    };

    final decision = selector.selectBestCandidate(
      eligibleContacts: [contactA, contactB],
      cadences: {
        ContactCircle.proches: 7,
        ContactCircle.eloignes: 7,
      },
      histories: histories,
      categoryPriorities: {
        ContactCircle.proches: 1,
        ContactCircle.eloignes: 2,
      },
      eligibilityByContactId: const {
        'a': EligibilityResult.eligible,
        'b': EligibilityResult.eligible,
      },
      nowUtc: now,
    );

    expect(decision.contact?.id, 'a');
    expect(decision.reason, isNot('no_suggestion'));
  });

  test('SuggestionSelector applique les tie-breakers dernier contact puis priorite', () {
    final selector = SuggestionSelector();
    final now = DateTime.utc(2026, 1, 10, 12);

    final contactA = Contact(
      id: 'a',
      displayName: 'Alice',
      circle: ContactCircle.proches,
      createdAt: DateTime.utc(2025, 12, 1).toIso8601String(),
    );
    final contactB = Contact(
      id: 'b',
      displayName: 'Benoit',
      circle: ContactCircle.eloignes,
      createdAt: DateTime.utc(2025, 12, 1).toIso8601String(),
    );

    final histories = {
      'a': [
        ContactHistoryEntry(
          id: 1,
          contactId: 'a',
          actionType: 'call',
          occurredAt: DateTime.utc(2026, 1, 2).toIso8601String(),
        ),
      ],
      'b': [
        ContactHistoryEntry(
          id: 2,
          contactId: 'b',
          actionType: 'call',
          occurredAt: DateTime.utc(2026, 1, 2).toIso8601String(),
        ),
      ],
    };

    final decision = selector.selectBestCandidate(
      eligibleContacts: [contactA, contactB],
      cadences: {
        ContactCircle.proches: 7,
        ContactCircle.eloignes: 7,
      },
      histories: histories,
      categoryPriorities: {
        ContactCircle.proches: 2,
        ContactCircle.eloignes: 1,
      },
      eligibilityByContactId: const {
        'a': EligibilityResult.eligible,
        'b': EligibilityResult.eligible,
      },
      nowUtc: now,
    );

    expect(decision.contact?.id, 'b');
  });

  test('SuggestionSelector retourne no_suggestion si aucun eligible', () {
    final selector = SuggestionSelector();

    final decision = selector.selectBestCandidate(
      eligibleContacts: const [],
      cadences: const {},
      histories: const {},
      categoryPriorities: const {},
      eligibilityByContactId: const {},
      nowUtc: DateTime.utc(2026, 1, 10),
    );

    expect(decision.contact, isNull);
    expect(decision.reason, 'no_suggestion');
  });

  test('SuggestionSelector ignore les contacts pas encore dus', () {
    final selector = SuggestionSelector();
    final now = DateTime.utc(2026, 1, 10, 12);

    final contact = Contact(
      id: 'a',
      displayName: 'Alice',
      circle: ContactCircle.proches,
      createdAt: DateTime.utc(2026, 1, 10, 11).toIso8601String(),
    );

    final decision = selector.selectBestCandidate(
      eligibleContacts: [contact],
      cadences: {
        ContactCircle.proches: 7,
      },
      histories: const {},
      categoryPriorities: const {ContactCircle.proches: 1},
      eligibilityByContactId: const {
        'a': EligibilityResult.eligible,
      },
      nowUtc: now,
    );

    expect(decision.contact, isNull);
    expect(decision.reason, 'no_suggestion');
  });

  test('SuggestionSelector respecte les contraintes d\'eligibilite', () {
    final selector = SuggestionSelector();
    final now = DateTime.utc(2026, 1, 10, 12);

    final contactA = Contact(
      id: 'a',
      displayName: 'Alice',
      circle: ContactCircle.proches,
      createdAt: DateTime.utc(2025, 12, 1).toIso8601String(),
    );
    final contactB = Contact(
      id: 'b',
      displayName: 'Benoit',
      circle: ContactCircle.eloignes,
      createdAt: DateTime.utc(2025, 12, 1).toIso8601String(),
    );

    final decision = selector.selectBestCandidate(
      eligibleContacts: [contactA, contactB],
      cadences: {
        ContactCircle.proches: 7,
        ContactCircle.eloignes: 7,
      },
      histories: const {},
      categoryPriorities: const {
        ContactCircle.proches: 1,
        ContactCircle.eloignes: 2,
      },
      eligibilityByContactId: const {
        'a': EligibilityResult.cooldown,
        'b': EligibilityResult.eligible,
      },
      nowUtc: now,
    );

    expect(decision.contact?.id, 'b');
  });

  test('SuggestionSelector applique un tie-breaker stable sur l\'id', () {
    final selector = SuggestionSelector();
    final now = DateTime.utc(2026, 1, 10, 12);

    final contactA = Contact(
      id: 'a',
      displayName: 'Alice',
      circle: ContactCircle.proches,
      createdAt: DateTime.utc(2026, 1, 1).toIso8601String(),
    );
    final contactB = Contact(
      id: 'b',
      displayName: 'Benoit',
      circle: ContactCircle.proches,
      createdAt: DateTime.utc(2026, 1, 1).toIso8601String(),
    );

    final history = [
      ContactHistoryEntry(
        id: 1,
        contactId: 'a',
        actionType: 'call',
        occurredAt: DateTime.utc(2026, 1, 1).toIso8601String(),
      ),
    ];

    final decision = selector.selectBestCandidate(
      eligibleContacts: [contactB, contactA],
      cadences: {
        ContactCircle.proches: 7,
      },
      histories: {
        'a': history,
        'b': history
            .map(
              (entry) => ContactHistoryEntry(
                id: entry.id,
                contactId: 'b',
                actionType: entry.actionType,
                occurredAt: entry.occurredAt,
              ),
            )
            .toList(),
      },
      categoryPriorities: const {
        ContactCircle.proches: 1,
      },
      eligibilityByContactId: const {
        'a': EligibilityResult.eligible,
        'b': EligibilityResult.eligible,
      },
      nowUtc: now,
    );

    expect(decision.contact?.id, 'a');
  });
}
