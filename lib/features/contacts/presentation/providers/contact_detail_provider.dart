import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/contact_history_repository.dart';
import '../../domain/contact.dart';
import '../../domain/contact_circle.dart';
import '../../domain/contact_suggestion_service.dart';
import '../../domain/contact_history_entry.dart';
import '../../domain/contacts_service.dart';
import 'contacts_provider.dart';
import 'onboarding_cadence_provider.dart';
import 'onboarding_contacts_provider.dart';

final contactHistoryRepositoryProvider = Provider<ContactHistoryRepository>(
  (ref) => ContactHistoryRepositoryImpl(AppDatabase.instance),
);

final contactSuggestionServiceProvider = Provider<ContactSuggestionService>(
  (ref) => ContactSuggestionService(),
);

final contactDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ContactDetailNotifier, ContactDetailState, String>(
  ContactDetailNotifier.new,
);

class ContactDetailState {
  const ContactDetailState({
    required this.contact,
    required this.cadenceDays,
    required this.nextSuggestedAt,
    required this.recentHistory,
    this.isUpdating = false,
  });

  final Contact contact;
  final int cadenceDays;
  final DateTime? nextSuggestedAt;
  final List<ContactHistoryEntry> recentHistory;
  final bool isUpdating;

  ContactDetailState copyWith({
    Contact? contact,
    int? cadenceDays,
    DateTime? nextSuggestedAt,
    List<ContactHistoryEntry>? recentHistory,
    bool? isUpdating,
  }) {
    return ContactDetailState(
      contact: contact ?? this.contact,
      cadenceDays: cadenceDays ?? this.cadenceDays,
      nextSuggestedAt: nextSuggestedAt ?? this.nextSuggestedAt,
      recentHistory: recentHistory ?? this.recentHistory,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

class ContactDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<ContactDetailState, String> {
  late final String _contactId;

  @override
  Future<ContactDetailState> build(String arg) async {
    _contactId = arg;
    final service = ref.read(contactsServiceProvider);
    final contact = await service.loadContactById(arg);
    final cadenceService = ref.read(cadenceServiceProvider);
    final cadences = await cadenceService.loadCadencesForCircles(
      [contact.circle],
    );
    final historyRepository = ref.read(contactHistoryRepositoryProvider);
    final history = await historyRepository.fetchRecentHistory(arg);
    final suggestionService = ref.read(contactSuggestionServiceProvider);
    final nextSuggestedAt = suggestionService.computeNextSuggestedAt(
      contact: contact,
      cadenceDays: cadences.first.cadenceDays,
      history: history,
    );
    return ContactDetailState(
      contact: contact,
      cadenceDays: cadences.first.cadenceDays,
      nextSuggestedAt: nextSuggestedAt,
      recentHistory: history,
    );
  }

  Future<bool> updateContact({
    required String displayName,
    required ContactCircle circle,
    String? phone,
    String? email,
  }) async {
    final current = state.value;
    if (current == null) {
      return false;
    }
    if (current.isUpdating) {
      return false;
    }
    state = AsyncData(current.copyWith(isUpdating: true));
    try {
      final service = ref.read(contactsServiceProvider);
      final updated = await service.updateContact(
        id: _contactId,
        displayName: displayName,
        circle: circle,
        phone: phone,
        email: email,
      );
      final cadenceService = ref.read(cadenceServiceProvider);
      final cadences = await cadenceService.loadCadencesForCircles(
        [updated.circle],
      );
      final historyRepository = ref.read(contactHistoryRepositoryProvider);
      final history = await historyRepository.fetchRecentHistory(_contactId);
      final suggestionService = ref.read(contactSuggestionServiceProvider);
      final nextSuggestedAt = suggestionService.computeNextSuggestedAt(
        contact: updated,
        cadenceDays: cadences.first.cadenceDays,
        history: history,
      );
      ref.read(contactsProvider.notifier).updateContactInList(updated);
      state = AsyncData(
        current.copyWith(
          contact: updated,
          cadenceDays: cadences.first.cadenceDays,
          nextSuggestedAt: nextSuggestedAt,
          recentHistory: history,
          isUpdating: false,
        ),
      );
      return true;
    } catch (_) {
      state = AsyncData(current.copyWith(isUpdating: false));
      return false;
    }
  }

  Future<bool> updateContactCircle(ContactCircle circle) async {
    final current = state.value;
    if (current == null) {
      return false;
    }
    if (current.isUpdating) {
      return false;
    }
    if (current.contact.circle == circle) {
      return true;
    }
    state = AsyncData(current.copyWith(isUpdating: true));
    try {
      final service = ref.read(contactsServiceProvider);
      final updated = await service.updateContact(
        id: _contactId,
        displayName: current.contact.displayName,
        circle: circle,
        phone: current.contact.phone,
        email: current.contact.email,
      );
      final cadenceService = ref.read(cadenceServiceProvider);
      final cadences = await cadenceService.loadCadencesForCircles(
        [updated.circle],
      );
      final historyRepository = ref.read(contactHistoryRepositoryProvider);
      final history = await historyRepository.fetchRecentHistory(_contactId);
      final suggestionService = ref.read(contactSuggestionServiceProvider);
      final nextSuggestedAt = suggestionService.computeNextSuggestedAt(
        contact: updated,
        cadenceDays: cadences.first.cadenceDays,
        history: history,
      );
      ref.read(contactsProvider.notifier).updateContactInList(updated);
      state = AsyncData(
        current.copyWith(
          contact: updated,
          cadenceDays: cadences.first.cadenceDays,
          nextSuggestedAt: nextSuggestedAt,
          recentHistory: history,
          isUpdating: false,
        ),
      );
      return true;
    } catch (_) {
      state = AsyncData(current.copyWith(isUpdating: false));
      return false;
    }
  }

  Future<bool> deleteContact() async {
    final current = state.value;
    if (current == null) {
      return false;
    }
    if (current.isUpdating) {
      return false;
    }
    state = AsyncData(current.copyWith(isUpdating: true));
    try {
      final service = ref.read(contactsServiceProvider);
      await service.deleteContact(_contactId);
      ref.read(contactsProvider.notifier).removeContactById(_contactId);
      state = AsyncData(current.copyWith(isUpdating: false));
      return true;
    } catch (_) {
      state = AsyncData(current.copyWith(isUpdating: false));
      return false;
    }
  }
}
