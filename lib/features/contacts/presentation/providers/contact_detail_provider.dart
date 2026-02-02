import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/contact.dart';
import '../../domain/contact_circle.dart';
import '../../domain/contacts_service.dart';
import 'contacts_provider.dart';
import 'onboarding_contacts_provider.dart';

final contactDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ContactDetailNotifier, ContactDetailState, String>(
  ContactDetailNotifier.new,
);

class ContactDetailState {
  const ContactDetailState({
    required this.contact,
    this.isUpdating = false,
  });

  final Contact contact;
  final bool isUpdating;

  ContactDetailState copyWith({
    Contact? contact,
    bool? isUpdating,
  }) {
    return ContactDetailState(
      contact: contact ?? this.contact,
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
    return ContactDetailState(contact: contact);
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
      ref.read(contactsProvider.notifier).updateContactInList(updated);
      state = AsyncData(
        current.copyWith(
          contact: updated,
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
