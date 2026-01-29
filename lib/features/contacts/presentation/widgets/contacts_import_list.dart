import 'package:flutter/material.dart';

import '../../domain/imported_contact.dart';

class ContactsImportList extends StatefulWidget {
  const ContactsImportList({
    super.key,
    required this.contacts,
    required this.selectedIds,
    required this.onToggleSelection,
    required this.query,
    required this.onQueryChanged,
  });

  final List<ImportedContact> contacts;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggleSelection;
  final String query;
  final ValueChanged<String> onQueryChanged;

  @override
  State<ContactsImportList> createState() => _ContactsImportListState();
}

class _ContactsImportListState extends State<ContactsImportList> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant ContactsImportList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query && _controller.text != widget.query) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selectionnez vos contacts',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: widget.onQueryChanged,
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Rechercher un contact',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: widget.contacts.isEmpty
              ? Center(
                  child: Text(
                    'Aucun contact a afficher.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                )
              : ListView.separated(
                  itemCount: widget.contacts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = widget.contacts[index];
                    final isSelected = widget.selectedIds.contains(contact.id);
                    return CheckboxListTile(
                      key: ValueKey('import-contact-${contact.id}'),
                      value: isSelected,
                      onChanged: (_) => widget.onToggleSelection(contact.id),
                      title: Text(contact.displayName),
                      subtitle: contact.phone != null || contact.email != null
                          ? Text(
                              contact.phone ?? contact.email ?? '',
                            )
                          : null,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
