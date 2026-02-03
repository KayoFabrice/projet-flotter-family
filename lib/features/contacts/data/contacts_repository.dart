import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/contact.dart';
import '../domain/contact_circle.dart';

abstract class ContactsRepository {
  Future<List<Contact>> fetchContacts();
  Future<List<Contact>> searchContacts(String query);
  Future<List<Contact>> fetchOnboardingContacts();
  Future<Contact?> fetchContactById(String id);
  Future<void> createContact(Contact contact);
  Future<void> createOnboardingContact(Contact contact);
  Future<void> createImportedContacts(List<Contact> contacts);
  Future<void> updateContact(Contact contact);
  Future<void> deleteContact(String id);
  Future<int> countOnboardingContacts();
}

class ContactsRepositoryImpl implements ContactsRepository {
  ContactsRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<Contact>> fetchContacts() async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.contactsTable,
      orderBy: 'display_name COLLATE NOCASE ASC',
    );
    return _mapRows(rows);
  }

  @override
  Future<List<Contact>> searchContacts(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return fetchContacts();
    }
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.contactsTable,
      where: 'LOWER(display_name) LIKE ?',
      whereArgs: ['%${trimmed.toLowerCase()}%'],
      orderBy: 'display_name COLLATE NOCASE ASC',
    );
    return _mapRows(rows);
  }

  @override
  Future<List<Contact>> fetchOnboardingContacts() async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.contactsTable,
      where: 'is_onboarding = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return _mapRows(rows);
  }

  @override
  Future<Contact?> fetchContactById(String id) async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.contactsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return _mapRows(rows).first;
  }

  @override
  Future<void> createContact(Contact contact) async {
    final db = await _database.database;
    await db.insert(
      AppDatabase.contactsTable,
      {
        'id': contact.id,
        'display_name': contact.displayName,
        'circle': contact.circle.storageValue,
        'created_at': contact.createdAt,
        'is_onboarding': 0,
        'phone': contact.phone,
        'email': contact.email,
      },
    );
  }

  @override
  Future<void> updateContact(Contact contact) async {
    final db = await _database.database;
    await db.update(
      AppDatabase.contactsTable,
      {
        'display_name': contact.displayName,
        'circle': contact.circle.storageValue,
        'phone': contact.phone,
        'email': contact.email,
      },
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  @override
  Future<void> deleteContact(String id) async {
    final db = await _database.database;
    await db.transaction((transaction) async {
      final deletedCount = await transaction.delete(
        AppDatabase.contactsTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (deletedCount == 0) {
        throw StateError('Contact introuvable');
      }
      await _deleteContactReferences(transaction, contactId: id);
    });
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
        'phone': contact.phone,
        'email': contact.email,
      },
    );
  }

  @override
  Future<void> createImportedContacts(List<Contact> contacts) async {
    if (contacts.isEmpty) {
      return;
    }
    final db = await _database.database;
    await db.transaction((transaction) async {
      final batch = transaction.batch();
      for (final contact in contacts) {
        batch.insert(
          AppDatabase.contactsTable,
          {
            'id': contact.id,
            'display_name': contact.displayName,
            'circle': contact.circle.storageValue,
            'created_at': contact.createdAt,
            'is_onboarding': 0,
            'phone': contact.phone,
            'email': contact.email,
          },
        );
      }
      await batch.commit(noResult: true);
    });
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

  List<Contact> _mapRows(List<Map<String, Object?>> rows) {
    return rows
        .map(
          (row) => Contact(
            id: (row['id'] as String?) ?? '',
            displayName: (row['display_name'] as String?) ?? '',
            circle: ContactCircleMapping.fromStorage(
              (row['circle'] as String?) ?? 'proches',
            ),
            createdAt: (row['created_at'] as String?) ?? '',
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            cooldownUntil: row['cooldown_until'] as String?,
          ),
        )
        .toList();
  }

  Future<void> _deleteContactReferences(
    DatabaseExecutor database, {
    required String contactId,
  }) async {
    final tables = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    for (final row in tables) {
      final table = row['name'];
      if (table is! String) {
        continue;
      }
      final columns = await database.rawQuery('PRAGMA table_info($table)');
      final hasContactId =
          columns.any((column) => column['name'] == 'contact_id');
      if (!hasContactId) {
        continue;
      }
      await database.delete(
        table,
        where: 'contact_id = ?',
        whereArgs: [contactId],
      );
    }
  }
}
