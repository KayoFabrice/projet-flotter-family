import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/contact.dart';
import '../../domain/contact_circle.dart';
import '../../domain/contacts_service.dart';
import 'onboarding_contacts_provider.dart';

final contactsDebounceDurationProvider = Provider<Duration>((ref) {
  return const Duration(milliseconds: 250);
});

final contactsProvider =
    AsyncNotifierProvider<ContactsNotifier, ContactsState>(
  ContactsNotifier.new,
);

class ContactsState {
  const ContactsState({
    required this.allContacts,
    required this.filteredContacts,
  });

  final List<Contact> allContacts;
  final List<Contact> filteredContacts;
}

class ContactsNotifier extends AsyncNotifier<ContactsState> {
  List<Contact> _allContacts = const [];
  String _query = '';
  Timer? _debounceTimer;
  bool _pendingFilter = false;

  @override
  Future<ContactsState> build() async {
    ref.onDispose(_cancelDebounce);
    final service = ref.read(contactsServiceProvider);
    _allContacts = await service.loadContacts();
    final filtered = _applyQuery(_allContacts, _query);
    _pendingFilter = false;
    return ContactsState(
      allContacts: _allContacts,
      filteredContacts: filtered,
    );
  }

  void updateQuery(String query) {
    _query = query;
    final debounceDuration = ref.read(contactsDebounceDurationProvider);
    if (debounceDuration == Duration.zero) {
      _emitFiltered();
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, _emitFiltered);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(contactsServiceProvider);
      _allContacts = await service.loadContacts();
      final filtered = _applyQuery(_allContacts, _query);
      _pendingFilter = false;
      return ContactsState(
        allContacts: _allContacts,
        filteredContacts: filtered,
      );
    });
  }

  void _emitFiltered() {
    if (state.isLoading) {
      _pendingFilter = true;
      return;
    }
    state = AsyncData(
      ContactsState(
        allContacts: _allContacts,
        filteredContacts: _applyQuery(_allContacts, _query),
      ),
    );
  }

  Future<bool> addContact({
    required String displayName,
    required ContactCircle circle,
  }) async {
    final service = ref.read(contactsServiceProvider);
    final current = state.value?.allContacts ?? _allContacts;
    final nextState = await AsyncValue.guard(() async {
      final contact = await service.createContact(
        displayName: displayName,
        circle: circle,
      );
      _allContacts = [...current, contact];
      _pendingFilter = false;
      return ContactsState(
        allContacts: _allContacts,
        filteredContacts: _applyQuery(_allContacts, _query),
      );
    });
    if (nextState.hasError) {
      state = AsyncData(
        ContactsState(
          allContacts: current,
          filteredContacts: _applyQuery(current, _query),
        ),
      );
      return false;
    }
    state = nextState;
    return true;
  }

  List<Contact> _applyQuery(List<Contact> contacts, String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return contacts;
    }
    return contacts
        .where(
          (contact) => contact.displayName.toLowerCase().contains(trimmed),
        )
        .toList();
  }

  void _cancelDebounce() {
    _debounceTimer?.cancel();
  }
}
