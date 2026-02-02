import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/contact_circle.dart';
import '../providers/contact_detail_provider.dart';
import '../providers/contact_form_provider.dart';
import '../widgets/contact_form.dart';

enum ContactEditResult { updated, deleted }

class ContactEditArgs {
  const ContactEditArgs.create() : contactId = null;

  const ContactEditArgs.edit({required this.contactId});

  final String? contactId;

  bool get isEditing => contactId != null;
}

class ContactEditPage extends ConsumerStatefulWidget {
  const ContactEditPage({super.key, this.args});

  static const addRouteName = '/contacts/add';
  static const editRouteName = '/contacts/edit';

  final ContactEditArgs? args;

  @override
  ConsumerState<ContactEditPage> createState() => _ContactEditPageState();
}

class _ContactEditPageState extends ConsumerState<ContactEditPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  ContactCircle? _selectedCircle;
  String? _nameError;
  String? _circleError;
  bool _isSubmitting = false;
  bool _seededFromContact = false;

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

  Future<void> _saveEditedContact(String contactId) async {
    if (_isSubmitting) {
      return;
    }
    final trimmedName = _nameController.text.trim();
    final circle = _selectedCircle;
    setState(() {
      _nameError = trimmedName.isEmpty ? 'Nom requis' : null;
      _circleError = circle == null ? 'Relation requise' : null;
    });
    if (_nameError != null || _circleError != null) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    final success = await ref
        .read(contactDetailProvider(contactId).notifier)
        .updateContact(
          displayName: trimmedName,
          circle: circle!,
          phone: _optionalValue(_phoneController.text),
          email: _optionalValue(_emailController.text),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _isSubmitting = false;
    });
    if (success) {
      Navigator.of(context).pop(ContactEditResult.updated);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impossible de mettre à jour le proche.'),
      ),
    );
  }

  Future<void> _confirmDelete(String contactId) async {
    if (_isSubmitting) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer ce contact ?'),
          content: const Text(
            'Cette action est definitive.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    final deleted =
        await ref.read(contactDetailProvider(contactId).notifier).deleteContact();
    if (!mounted) {
      return;
    }
    setState(() {
      _isSubmitting = false;
    });
    if (deleted) {
      Navigator.of(context).pop(ContactEditResult.deleted);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impossible de supprimer le proche.'),
      ),
    );
  }

  String? _optionalValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  void _seedControllersFromContact(ContactCircle circle, String name,
      String? phone, String? email) {
    if (_seededFromContact) {
      return;
    }
    _seededFromContact = true;
    _nameController.text = name;
    _phoneController.text = phone ?? '';
    _emailController.text = email ?? '';
    _selectedCircle = circle;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedArgs = widget.args ??
        ModalRoute.of(context)?.settings.arguments as ContactEditArgs?;
    final args = resolvedArgs ?? const ContactEditArgs.create();
    final isEditing = args.isEditing;

    if (isEditing) {
      final contactId = args.contactId!;
      final detailState = ref.watch(contactDetailProvider(contactId));
      return Scaffold(
        appBar: AppBar(
          title: const Text('Modifier le contact'),
        ),
        body: detailState.when(
          data: (state) {
            _seedControllersFromContact(
              state.contact.circle,
              state.contact.displayName,
              state.contact.phone,
              state.contact.email,
            );
            final isBusy = state.isUpdating || _isSubmitting;
            return SafeArea(
              child: ContactForm(
                nameController: _nameController,
                phoneController: _phoneController,
                emailController: _emailController,
                selectedCircle: _selectedCircle,
                nameErrorText: _nameError,
                circleErrorText: _circleError,
                isSubmitting: isBusy,
                onNameChanged: (value) {
                  setState(() {
                    _nameError = null;
                  });
                },
                onPhoneChanged: (_) {},
                onEmailChanged: (_) {},
                onCircleSelected: (circle) {
                  setState(() {
                    _selectedCircle = circle;
                    _circleError = null;
                  });
                },
                onSubmit: () => _saveEditedContact(contactId),
                onSecondaryAction: () => _confirmDelete(contactId),
                secondaryActionLabel: 'Supprimer ce contact',
                secondaryActionIsDestructive: true,
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (_, __) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Erreur de chargement du contact.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(contactDetailProvider(contactId));
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
          onSecondaryAction: () {
            Navigator.of(context).pop();
          },
          secondaryActionLabel: 'Annuler',
        ),
      ),
    );
  }
}
