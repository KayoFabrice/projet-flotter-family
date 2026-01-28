import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/contacts_repository.dart';
import '../../domain/contact.dart';
import '../../domain/contact_circle.dart';
import '../../domain/contacts_service.dart';

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepositoryImpl(AppDatabase.instance);
});

final contactsServiceProvider = Provider<ContactsService>((ref) {
  final repository = ref.read(contactsRepositoryProvider);
  return ContactsService(repository);
});

final onboardingContactsProvider =
    AsyncNotifierProvider<OnboardingContactsNotifier, List<Contact>>(
  OnboardingContactsNotifier.new,
);

class OnboardingContactsNotifier extends AsyncNotifier<List<Contact>> {
  @override
  Future<List<Contact>> build() async {
    final service = ref.read(contactsServiceProvider);
    return service.loadOnboardingContacts();
  }

  Future<bool> addContact({
    required String displayName,
    required ContactCircle circle,
  }) async {
    final service = ref.read(contactsServiceProvider);
    final current = state.value ?? const <Contact>[];
    final nextState = await AsyncValue.guard(() async {
      final contact = await service.createOnboardingContact(
        displayName: displayName,
        circle: circle,
      );
      return [...current, contact];
    });
    if (nextState.hasError) {
      state = AsyncData(current);
      return false;
    }
    state = nextState;
    return true;
  }
}
