import '../../contacts/data/cadence_repository.dart';
import '../../contacts/data/contacts_repository.dart';
import '../../contacts/data/contact_history_repository.dart';
import '../../contacts/domain/contact.dart';
import '../../contacts/domain/contact_circle.dart';
import '../../contacts/domain/contact_history_entry.dart';
import '../data/reminders_repository.dart';
import 'eligibility_result.dart';
import 'reminder_rules.dart';
import 'suggestion_selector.dart';

class ReminderSuggestionService {
  ReminderSuggestionService({
    required ContactsRepository contactsRepository,
    required CadenceRepository cadenceRepository,
    required ContactHistoryRepository historyRepository,
    required RemindersRepository remindersRepository,
    ReminderRules? reminderRules,
    SuggestionSelector? selector,
  })  : _contactsRepository = contactsRepository,
        _cadenceRepository = cadenceRepository,
        _historyRepository = historyRepository,
        _remindersRepository = remindersRepository,
        _reminderRules = reminderRules ?? ReminderRules(),
        _selector = selector ?? SuggestionSelector();

  final ContactsRepository _contactsRepository;
  final CadenceRepository _cadenceRepository;
  final ContactHistoryRepository _historyRepository;
  final RemindersRepository _remindersRepository;
  final ReminderRules _reminderRules;
  final SuggestionSelector _selector;

  Future<SuggestionDecision> selectSuggestion({
    required String? currentLocationLabel,
    required int currentMinuteOfDay,
    Map<ContactCircle, int> categoryPriorities = const {},
    DateTime? nowUtc,
  }) async {
    final now = (nowUtc ?? DateTime.now()).toUtc();
    final contacts = await _contactsRepository.fetchContacts();
    if (contacts.isEmpty) {
      return SuggestionDecision.noSuggestion;
    }

    final cadences = await _cadenceRepository.fetchCadences();
    final keyLocations = await _remindersRepository.fetchKeyLocationLabels();
    final windows = await _remindersRepository.fetchAvailabilityWindows();
    final restWindows = await _remindersRepository.fetchRestWindows();

    final histories = <String, List<ContactHistoryEntry>>{};
    final eligibilityByContactId = <String, EligibilityResult>{};

    for (final contact in contacts) {
      final history = await _historyRepository.fetchRecentHistory(
        contact.id,
        limit: 1,
      );
      histories[contact.id] = history;
      final cooldownUntil =
          await _remindersRepository.fetchContactCooldownUntil(contact.id);
      final eligibility = _reminderRules.evaluateEligibility(
        currentLocationLabel: currentLocationLabel,
        keyLocations: keyLocations,
        currentMinuteOfDay: currentMinuteOfDay,
        windows: windows,
        restWindows: restWindows,
        nowUtc: now,
        cooldownUntil: cooldownUntil,
      );
      eligibilityByContactId[contact.id] = eligibility;
    }

    final priorities = categoryPriorities.isEmpty
        ? _defaultCategoryPriorities()
        : categoryPriorities;

    return _selector.selectBestCandidate(
      eligibleContacts: contacts,
      cadences: cadences,
      histories: histories,
      categoryPriorities: priorities,
      eligibilityByContactId: eligibilityByContactId,
      nowUtc: now,
    );
  }

  Map<ContactCircle, int> _defaultCategoryPriorities() {
    return {
      for (final circle in ContactCircle.values)
        circle: ContactCircle.values.indexOf(circle) + 1,
    };
  }
}
