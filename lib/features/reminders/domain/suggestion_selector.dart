import '../../contacts/domain/contact.dart';
import '../../contacts/domain/contact_circle.dart';
import '../../contacts/domain/contact_history_entry.dart';
import 'eligibility_result.dart';

class SuggestionDecision {
  const SuggestionDecision({
    required this.contact,
    required this.reason,
    this.message,
  });

  final Contact? contact;
  final String reason;
  final String? message;

  bool get hasSuggestion => contact != null;

  static const SuggestionDecision noSuggestion = SuggestionDecision(
    contact: null,
    reason: 'no_suggestion',
    message: null,
  );
}

class SuggestionSelector {
  SuggestionDecision selectBestCandidate({
    required List<Contact> eligibleContacts,
    required Map<ContactCircle, int> cadences,
    required Map<String, List<ContactHistoryEntry>> histories,
    required Map<ContactCircle, int> categoryPriorities,
    required Map<String, EligibilityResult> eligibilityByContactId,
    DateTime? nowUtc,
  }) {
    if (eligibleContacts.isEmpty) {
      return SuggestionDecision.noSuggestion;
    }

    final now = (nowUtc ?? DateTime.now()).toUtc();
    SelectionCandidate? best;

    for (final contact in eligibleContacts) {
      final eligibility = eligibilityByContactId[contact.id];
      if (eligibility == null || !eligibility.isEligible) {
        continue;
      }
      final cadenceDays = cadences[contact.circle] ?? 0;
      if (cadenceDays <= 0) {
        continue;
      }
      final history = histories[contact.id] ?? const <ContactHistoryEntry>[];
      final nextSuggestedAt = _computeNextSuggestedAt(
        contact: contact,
        cadenceDays: cadenceDays,
        history: history,
        now: now,
      );
      if (nextSuggestedAt == null) {
        continue;
      }
      final overdueMinutes = now.difference(nextSuggestedAt).inMinutes;
      if (overdueMinutes < 0) {
        continue;
      }
      final lastContactAt = _resolveLastContactAt(contact, history, now);
      final candidate = SelectionCandidate(
        contact: contact,
        overdueMinutes: overdueMinutes,
        lastContactAt: lastContactAt,
        categoryPriority: categoryPriorities[contact.circle] ?? 999,
      );

      if (best == null || _isBetterCandidate(candidate, best)) {
        best = candidate;
      }
    }

    if (best == null) {
      return SuggestionDecision.noSuggestion;
    }

    return SuggestionDecision(
      contact: best.contact,
      reason: _buildReason(best),
    );
  }

  bool _isBetterCandidate(SelectionCandidate candidate, SelectionCandidate best) {
    if (candidate.overdueMinutes != best.overdueMinutes) {
      return candidate.overdueMinutes > best.overdueMinutes;
    }
    if (!candidate.lastContactAt.isAtSameMomentAs(best.lastContactAt)) {
      return candidate.lastContactAt.isBefore(best.lastContactAt);
    }
    if (candidate.categoryPriority != best.categoryPriority) {
      return candidate.categoryPriority < best.categoryPriority;
    }
    return candidate.contact.id.compareTo(best.contact.id) < 0;
  }

  String _buildReason(SelectionCandidate candidate) {
    return 'selected=${candidate.contact.id}; '
        'overdue_minutes=${candidate.overdueMinutes}; '
        'last_contact_at=${candidate.lastContactAt.toIso8601String()}; '
        'category_priority=${candidate.categoryPriority}; '
        'rule=overdue,last_contact,category_priority,stable_id';
  }

  DateTime? _computeNextSuggestedAt({
    required Contact contact,
    required int cadenceDays,
    required List<ContactHistoryEntry> history,
    required DateTime now,
  }) {
    if (cadenceDays <= 0) {
      return null;
    }
    final baseDate = _resolveBaseDate(contact, history, now);
    if (baseDate == null) {
      return null;
    }
    return baseDate.add(Duration(days: cadenceDays));
  }

  DateTime? _resolveBaseDate(
    Contact contact,
    List<ContactHistoryEntry> history,
    DateTime now,
  ) {
    DateTime? latest;
    for (final entry in history) {
      final parsed = DateTime.tryParse(entry.occurredAt);
      if (parsed == null || parsed.isAfter(now)) {
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

  DateTime _resolveLastContactAt(
    Contact contact,
    List<ContactHistoryEntry> history,
    DateTime now,
  ) {
    final latest = _resolveBaseDate(contact, history, now);
    return latest ?? now;
  }
}

class SelectionCandidate {
  const SelectionCandidate({
    required this.contact,
    required this.overdueMinutes,
    required this.lastContactAt,
    required this.categoryPriority,
  });

  final Contact contact;
  final int overdueMinutes;
  final DateTime lastContactAt;
  final int categoryPriority;
}
