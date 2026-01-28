import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/contact.dart';
import '../domain/contact_circle.dart';

abstract class ContactsRepository {
  Future<List<Contact>> fetchOnboardingContacts();
  Future<void> createOnboardingContact(Contact contact);
  Future<int> countOnboardingContacts();
}

class ContactsRepositoryImpl implements ContactsRepository {
  ContactsRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<Contact>> fetchOnboardingContacts() async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.contactsTable,
      where: 'is_onboarding = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return rows
        .map(
          (row) => Contact(
            id: (row['id'] as int?) ?? 0,
            displayName: (row['display_name'] as String?) ?? '',
            circle: ContactCircleMapping.fromStorage(
              (row['circle'] as String?) ?? 'proches',
            ),
            createdAt: (row['created_at'] as String?) ?? '',
          ),
        )
        .toList();
  }

  @override
  Future<void> createOnboardingContact(Contact contact) async {
    final db = await _database.database;
    await db.insert(
      AppDatabase.contactsTable,
      {
        'id': contact.id,
        'display_name': contact.displayName,
        'circle': contact.circle.storageValue,
        'created_at': contact.createdAt,
        'is_onboarding': 1,
      },
    );
  }

  @override
  Future<int> countOnboardingContacts() async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${AppDatabase.contactsTable} WHERE is_onboarding = ?',
      [1],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
