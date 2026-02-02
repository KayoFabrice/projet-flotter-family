import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/contact_form_provider.dart';
import '../widgets/contact_form.dart';

class ContactEditPage extends ConsumerStatefulWidget {
  const ContactEditPage({super.key});

  static const routeName = '/contacts/add';

  @override
  ConsumerState<ContactEditPage> createState() => _ContactEditPageState();
}

class _ContactEditPageState extends ConsumerState<ContactEditPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    final result = await ref.read(contactFormProvider.notifier).submit();
    if (!mounted) {
      return;
    }
    if (result == ContactFormSubmitResult.success) {
      Navigator.of(context).pop();
      return;
    }
    if (result == ContactFormSubmitResult.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ajouter le proche.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(contactFormProvider);
    final state = formState.value ?? ContactFormState.initial();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un proche'),
      ),
      body: SafeArea(
        child: ContactForm(
          nameController: _nameController,
          phoneController: _phoneController,
          emailController: _emailController,
          selectedCircle: state.circle,
          nameErrorText: state.nameError,
          circleErrorText: state.circleError,
          isSubmitting: state.isSubmitting,
          onNameChanged: (value) {
            ref.read(contactFormProvider.notifier).updateName(value);
          },
          onPhoneChanged: (value) {
            ref.read(contactFormProvider.notifier).updatePhone(value);
          },
          onEmailChanged: (value) {
            ref.read(contactFormProvider.notifier).updateEmail(value);
          },
          onCircleSelected: (circle) {
            ref.read(contactFormProvider.notifier).updateCircle(circle);
          },
          onSubmit: _saveContact,
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
