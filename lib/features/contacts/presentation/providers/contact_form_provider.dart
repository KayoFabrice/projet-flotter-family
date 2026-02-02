import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/contact_circle.dart';
import 'contacts_provider.dart';
import 'onboarding_contacts_provider.dart';

final contactFormProvider =
    AsyncNotifierProvider.autoDispose<ContactFormNotifier, ContactFormState>(
  ContactFormNotifier.new,
);

enum ContactFormSubmitResult { success, validationFailed, failure }

class ContactFormState {
  static const Object _noChange = Object();

  const ContactFormState({
    required this.name,
    required this.phone,
    required this.email,
    required this.circle,
    required this.nameError,
    required this.circleError,
    required this.isSubmitting,
  });

  final String name;
  final String phone;
  final String email;
  final ContactCircle? circle;
  final String? nameError;
  final String? circleError;
  final bool isSubmitting;

  factory ContactFormState.initial() {
    return const ContactFormState(
      name: '',
      phone: '',
      email: '',
      circle: null,
      nameError: null,
      circleError: null,
      isSubmitting: false,
    );
  }

  ContactFormState copyWith({
    String? name,
    String? phone,
    String? email,
    ContactCircle? circle,
    Object? nameError = _noChange,
    Object? circleError = _noChange,
    bool? isSubmitting,
  }) {
    return ContactFormState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      circle: circle ?? this.circle,
      nameError: nameError == _noChange ? this.nameError : nameError as String?,
      circleError:
          circleError == _noChange ? this.circleError : circleError as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ContactFormNotifier extends AutoDisposeAsyncNotifier<ContactFormState> {
  @override
  Future<ContactFormState> build() async {
    return ContactFormState.initial();
  }

  void updateName(String value) {
    final current = state.value ?? ContactFormState.initial();
    state = AsyncData(
      current.copyWith(name: value, nameError: null),
    );
  }

  void updatePhone(String value) {
    final current = state.value ?? ContactFormState.initial();
    state = AsyncData(
      current.copyWith(phone: value),
    );
  }

  void updateEmail(String value) {
    final current = state.value ?? ContactFormState.initial();
    state = AsyncData(
      current.copyWith(email: value),
    );
  }

  void updateCircle(ContactCircle circle) {
    final current = state.value ?? ContactFormState.initial();
    state = AsyncData(
      current.copyWith(circle: circle, circleError: null),
    );
  }

  Future<ContactFormSubmitResult> submit() async {
    final current = state.value ?? ContactFormState.initial();
    if (current.isSubmitting) {
      return ContactFormSubmitResult.failure;
    }
    final trimmedName = current.name.trim();
    final nameError = trimmedName.isEmpty ? 'Nom requis' : null;
    final circleError = current.circle == null ? 'Relation requise' : null;
    if (nameError != null || circleError != null) {
      state = AsyncData(
        current.copyWith(
          nameError: nameError,
          circleError: circleError,
          isSubmitting: false,
        ),
      );
      return ContactFormSubmitResult.validationFailed;
    }

    state = AsyncData(
      current.copyWith(
        nameError: null,
        circleError: null,
        isSubmitting: true,
      ),
    );

    try {
      final service = ref.read(contactsServiceProvider);
      await service.createContact(
        displayName: trimmedName,
        circle: current.circle!,
        phone: _optionalValue(current.phone),
        email: _optionalValue(current.email),
      );
      await ref.read(contactsProvider.notifier).refresh();
      state = AsyncData(
        current.copyWith(isSubmitting: false),
      );
      return ContactFormSubmitResult.success;
    } catch (_) {
      state = AsyncData(
        current.copyWith(isSubmitting: false),
      );
      return ContactFormSubmitResult.failure;
    }
  }

  String? _optionalValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
