import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/domain/imported_contact.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/widgets/contacts_import_list.dart';

void main() {
  testWidgets('ContactsImportList shows contacts and selection state', (tester) async {
    final contacts = [
      const ImportedContact(id: '1', displayName: 'Alex', phone: '0600000000'),
      const ImportedContact(id: '2', displayName: 'Sarah', email: 'sarah@test.com'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContactsImportList(
            contacts: contacts,
            selectedIds: const {'1'},
            onToggleSelection: (_) {},
            query: '',
            onQueryChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Selectionnez vos contacts'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Sarah'), findsOneWidget);

    final alexTile = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('import-contact-1')),
    );
    expect(alexTile.value, isTrue);
  });
}
