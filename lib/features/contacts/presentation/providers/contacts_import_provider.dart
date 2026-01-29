import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/contacts_import_repository.dart';
import '../../data/contacts_repository.dart';
import '../../domain/contacts_import_service.dart';
import '../../domain/imported_contact.dart';
import '../../../../core/database/app_database.dart';

class ContactsImportState {
  const ContactsImportState({
    required this.contacts,
    required this.selectedIds,
    required this.query,
    required this.hasRequestedImport,
  });

  factory ContactsImportState.initial() {
    return const ContactsImportState(
      contacts: [],
      selectedIds: {},
      query: '',
      hasRequestedImport: false,
    );
  }

  final List<ImportedContact> contacts;
  final Set<String> selectedIds;
  final String query;
  final bool hasRequestedImport;

  List<ImportedContact> get filteredContacts {
    if (query.trim().isEmpty) {
      return contacts;
    }
    final lowerQuery = query.toLowerCase();
    return contacts
        .where((contact) => contact.displayName.toLowerCase().contains(lowerQuery))
        .toList();
  }

  ContactsImportState copyWith({
    List<ImportedContact>? contacts,
    Set<String>? selectedIds,
    String? query,
    bool? hasRequestedImport,
  }) {
    return ContactsImportState(
      contacts: contacts ?? this.contacts,
      selectedIds: selectedIds ?? this.selectedIds,
      query: query ?? this.query,
      hasRequestedImport: hasRequestedImport ?? this.hasRequestedImport,
    );
  }
}

final contactsImportRepositoryProvider = Provider<ContactsImportRepository>((ref) {
  return ContactsImportRepositoryImpl();
});

final contactsLocalRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepositoryImpl(AppDatabase.instance);
});

final contactsImportServiceProvider = Provider<ContactsImportService>((ref) {
  final importRepository = ref.read(contactsImportRepositoryProvider);
  final contactsRepository = ref.read(contactsLocalRepositoryProvider);
  return ContactsImportService(importRepository, contactsRepository);
});

final contactsImportProvider =
    AsyncNotifierProvider<ContactsImportNotifier, ContactsImportState>(
  ContactsImportNotifier.new,
);

class ContactsImportNotifier extends AsyncNotifier<ContactsImportState> {
  @override
  Future<ContactsImportState> build() async {
    return ContactsImportState.initial();
  }

  Future<void> loadContacts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(contactsImportServiceProvider);
      final contacts = await service.loadDeviceContacts();
      return ContactsImportState(
        contacts: contacts,
        selectedIds: {},
        query: '',
        hasRequestedImport: true,
      );
    });
  }

  void updateQuery(String query) {
    final value = state.valueOrNull;
    if (value == null) {
      return;
    }
    state = AsyncData(value.copyWith(query: query));
  }

  void toggleSelection(String contactId) {
    final value = state.valueOrNull;
    if (value == null) {
      return;
    }
    final updated = Set<String>.from(value.selectedIds);
    if (updated.contains(contactId)) {
      updated.remove(contactId);
    } else {
      updated.add(contactId);
    }
    state = AsyncData(value.copyWith(selectedIds: updated));
  }

  Future<bool> persistSelection() async {
    final value = state.valueOrNull;
    if (value == null) {
      return false;
    }
    final selected = value.contacts
        .where((contact) => value.selectedIds.contains(contact.id))
        .toList();
    try {
      final service = ref.read(contactsImportServiceProvider);
      await service.persistSelectedContacts(selected);
      return true;
    } catch (_) {
      return false;
    }
  }
}
