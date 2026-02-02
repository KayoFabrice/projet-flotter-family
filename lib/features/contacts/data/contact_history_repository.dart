import '../../../core/database/app_database.dart';
import '../domain/contact_history_entry.dart';

abstract class ContactHistoryRepository {
  Future<List<ContactHistoryEntry>> fetchRecentHistory(
    String contactId, {
    int limit = 5,
  });
}

class ContactHistoryRepositoryImpl implements ContactHistoryRepository {
  ContactHistoryRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<ContactHistoryEntry>> fetchRecentHistory(
    String contactId, {
    int limit = 5,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.contactHistoryTable,
      where: 'contact_id = ?',
      whereArgs: [contactId],
      orderBy: 'occurred_at DESC',
      limit: limit,
    );
    return rows
        .map(
          (row) => ContactHistoryEntry(
            id: (row['id'] as int?) ?? 0,
            contactId: (row['contact_id'] as String?) ?? '',
            actionType: (row['action_type'] as String?) ?? '',
            occurredAt: (row['occurred_at'] as String?) ?? '',
          ),
        )
        .toList();
  }
}
