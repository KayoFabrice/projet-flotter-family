import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/contact_circle.dart';
import '../providers/contacts_provider.dart';

class ContactEditPage extends ConsumerStatefulWidget {
  const ContactEditPage({super.key});

  static const routeName = '/contacts/add';

  @override
  ConsumerState<ContactEditPage> createState() => _ContactEditPageState();
}

class _ContactEditPageState extends ConsumerState<ContactEditPage> {
  final _nameController = TextEditingController();
  ContactCircle _circle = ContactCircle.proches;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Renseignez un nom pour continuer.'),
        ),
      );
      return;
    }
    setState(() {
      _saving = true;
    });
    final success = await ref.read(contactsProvider.notifier).addContact(
          displayName: name,
          circle: _circle,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
    });
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ajouter le proche.'),
        ),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un proche'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nom du proche',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Ex: Sarah Dupont',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Categorie',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ContactCircle>(
                value: _circle,
                items: ContactCircle.values
                    .map(
                      (circle) => DropdownMenuItem(
                        value: circle,
                        child: Text(circle.label),
                      ),
                    )
                    .toList(),
                onChanged: (circle) {
                  if (circle == null) {
                    return;
                  }
                  setState(() {
                    _circle = circle;
                  });
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _saveContact,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
