import 'contact.dart';
import 'contact_action_types.dart';
import 'contact_circle.dart';
import 'contact_history_entry.dart';

class ContactNextSuggestion {
  const ContactNextSuggestion({
    required this.contact,
    required this.nextSuggestedAt,
  });

  final Contact contact;
  final DateTime nextSuggestedAt;
}

class ContactSuggestionService {
  ContactSuggestionService({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  DateTime? computeNextSuggestedAt({
    required Contact contact,
    required int cadenceDays,
    required List<ContactHistoryEntry> history,
  }) {
    if (cadenceDays <= 0) {
      return null;
    }

    final now = _clock().toUtc();
    final baseDate = _resolveBaseDate(contact, history, now);
    if (baseDate == null) {
      return null;
    }

    return baseDate.add(Duration(days: cadenceDays));
  }

  ContactNextSuggestion? computeNextSuggestion({
    required List<Contact> contacts,
    required Map<ContactCircle, int> cadences,
    required Map<String, List<ContactHistoryEntry>> histories,
  }) {
    ContactNextSuggestion? best;
    for (final contact in contacts) {
      final cadenceDays = cadences[contact.circle] ?? 0;
      final history = histories[contact.id] ?? const <ContactHistoryEntry>[];
      final nextSuggestedAt = computeNextSuggestedAt(
        contact: contact,
        cadenceDays: cadenceDays,
        history: history,
      );
      if (nextSuggestedAt == null) {
        continue;
      }
      if (best == null ||
          nextSuggestedAt.isBefore(best.nextSuggestedAt) ||
          (nextSuggestedAt.isAtSameMomentAs(best.nextSuggestedAt) &&
              contact.displayName.compareTo(best.contact.displayName) < 0)) {
        best = ContactNextSuggestion(
          contact: contact,
          nextSuggestedAt: nextSuggestedAt,
        );
      }
    }
    return best;
  }

  DateTime? _resolveBaseDate(
    Contact contact,
    List<ContactHistoryEntry> history,
    DateTime now,
  ) {
    DateTime? latest;
    for (final entry in history) {
      if (ContactActionTypes.isAttempt(entry.actionType)) {
        continue;
      }
      final parsed = DateTime.tryParse(entry.occurredAt);
      if (parsed == null) {
        continue;
      }
      if (parsed.isAfter(now)) {
        continue;
      }
      if (latest == null || parsed.isAfter(latest)) {
        latest = parsed;
      }
    }
    if (latest != null) {
      return latest;
    }
    final createdAt = DateTime.tryParse(contact.createdAt);
    if (createdAt == null) {
      return null;
    }
    if (createdAt.isAfter(now)) {
      return now;
    }
    return createdAt;
  }
}
