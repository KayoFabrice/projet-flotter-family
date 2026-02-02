import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:projet_flutter_famille/core/database/app_database.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('ContactsRepository.deleteContact nettoie les references liees', () async {
    final database = AppDatabase.instance;
    final db = await database.database;

    await db.delete(AppDatabase.contactHistoryTable);
    await db.delete(AppDatabase.contactCadenceOverridesTable);
    await db.delete(AppDatabase.contactsTable);

    final contact = Contact(
      id: 'contact-1',
      displayName: 'Maman',
      circle: ContactCircle.proches,
      createdAt: DateTime(2026, 1, 10).toUtc().toIso8601String(),
      phone: '+33 6 12 34 56 78',
    );

    await db.insert(AppDatabase.contactsTable, {
      'id': contact.id,
      'display_name': contact.displayName,
      'circle': contact.circle.storageValue,
      'created_at': contact.createdAt,
      'is_onboarding': 0,
      'phone': contact.phone,
      'email': contact.email,
    });

    await db.insert(AppDatabase.contactCadenceOverridesTable, {
      'contact_id': contact.id,
      'cadence_days': 14,
    });

    await db.insert(AppDatabase.contactHistoryTable, {
      'contact_id': contact.id,
      'action_type': 'call',
      'occurred_at': DateTime(2026, 1, 15).toUtc().toIso8601String(),
    });

    final repository = ContactsRepositoryImpl(database);
    await repository.deleteContact(contact.id);

    final contactRows = await db.query(
      AppDatabase.contactsTable,
      where: 'id = ?',
      whereArgs: [contact.id],
    );
    final cadenceRows = await db.query(
      AppDatabase.contactCadenceOverridesTable,
      where: 'contact_id = ?',
      whereArgs: [contact.id],
    );
    final historyRows = await db.query(
      AppDatabase.contactHistoryTable,
      where: 'contact_id = ?',
      whereArgs: [contact.id],
    );

    expect(contactRows, isEmpty);
    expect(cadenceRows, isEmpty);
    expect(historyRows, isEmpty);
  });
}
