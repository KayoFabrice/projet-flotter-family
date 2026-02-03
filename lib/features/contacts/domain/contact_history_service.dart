import '../data/contact_history_repository.dart';
import 'contact_action_types.dart';

class ContactHistoryService {
  ContactHistoryService({
    required ContactHistoryRepository repository,
    DateTime Function()? nowUtc,
  })  : _repository = repository,
        _nowUtc = nowUtc ?? (() => DateTime.now().toUtc());

  final ContactHistoryRepository _repository;
  final DateTime Function() _nowUtc;

  Future<void> recordAction({
    required String contactId,
    required String actionType,
    DateTime? occurredAtUtc,
  }) async {
    final occurredAt = (occurredAtUtc ?? _nowUtc()).toUtc();
    await _repository.addHistoryEntry(
      contactId: contactId,
      actionType: actionType,
      occurredAt: occurredAt.toIso8601String(),
    );
  }

  Future<void> recordWriteAttempt({
    required String contactId,
    DateTime? occurredAtUtc,
  }) {
    return recordAction(
      contactId: contactId,
      actionType: ContactActionTypes.writeAttempt,
      occurredAtUtc: occurredAtUtc,
    );
  }

  Future<void> recordWriteSuccess({
    required String contactId,
    DateTime? occurredAtUtc,
  }) {
    return recordAction(
      contactId: contactId,
      actionType: ContactActionTypes.writeSuccess,
      occurredAtUtc: occurredAtUtc,
    );
  }
}
