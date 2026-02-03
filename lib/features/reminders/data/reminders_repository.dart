import '../../settings/data/availability_repository.dart';
import '../../settings/data/key_location_repository.dart';
import '../../settings/data/settings_flags_repository.dart';
import '../domain/rest_window.dart';
import 'rest_window_repository.dart';
import '../../settings/domain/availability_window.dart';
import '../../../core/database/app_database.dart';

abstract class RemindersRepository {
  Future<List<String>> fetchKeyLocationLabels();
  Future<List<AvailabilityWindow>> fetchAvailabilityWindows();
  Future<List<RestWindow>> fetchRestWindows();
  Future<Duration> fetchCooldownDuration();
  Future<void> saveCooldownDuration(Duration duration);
  Future<void> setContactCooldownUntil({
    required String contactId,
    required String cooldownUntil,
  });
  Future<String?> fetchContactCooldownUntil(String contactId);
}

class RemindersRepositoryImpl implements RemindersRepository {
  RemindersRepositoryImpl({
    required AppDatabase database,
    required KeyLocationRepository keyLocationRepository,
    required AvailabilityRepository availabilityRepository,
    required RestWindowRepository restWindowRepository,
    required SettingsFlagsRepository settingsFlagsRepository,
  })  : _database = database,
        _keyLocationRepository = keyLocationRepository,
        _availabilityRepository = availabilityRepository,
        _restWindowRepository = restWindowRepository,
        _settingsFlagsRepository = settingsFlagsRepository;

  final AppDatabase _database;
  final KeyLocationRepository _keyLocationRepository;
  final AvailabilityRepository _availabilityRepository;
  final RestWindowRepository _restWindowRepository;
  final SettingsFlagsRepository _settingsFlagsRepository;

  static const Duration _defaultCooldownDuration = Duration(hours: 48);
  static const String _cooldownDurationHoursKey = 'reminder_cooldown_hours';
  static const RestWindow _defaultRestWindow = RestWindow(
    startMinute: 22 * 60,
    endMinute: 7 * 60,
  );
  static const String _useAvailabilityAsRestKey =
      'rest_mode_use_availability';

  @override
  Future<List<String>> fetchKeyLocationLabels() async {
    final location = await _keyLocationRepository.fetchKeyLocation();
    if (location == null || location.label.trim().isEmpty) {
      return const [];
    }
    final pieces = location.label.split(',');
    return pieces
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  Future<List<AvailabilityWindow>> fetchAvailabilityWindows() {
    return _availabilityRepository.fetchWindows();
  }

  @override
  Future<List<RestWindow>> fetchRestWindows() async {
    final useAvailability =
        await _settingsFlagsRepository.fetchBool(_useAvailabilityAsRestKey) ??
            false;
    if (useAvailability) {
      final availability = await _availabilityRepository.fetchWindows();
      if (availability.isNotEmpty) {
        return availability
            .map(
              (window) => RestWindow(
                startMinute: window.startMinute,
                endMinute: window.endMinute,
              ),
            )
            .toList();
      }
    }
    final windows = await _restWindowRepository.fetchWindows();
    if (windows.isNotEmpty) {
      return windows;
    }
    return const [_defaultRestWindow];
  }

  @override
  Future<Duration> fetchCooldownDuration() async {
    final raw = await _settingsFlagsRepository.fetchString(
      _cooldownDurationHoursKey,
    );
    if (raw == null || raw.trim().isEmpty) {
      return _defaultCooldownDuration;
    }
    final hours = int.tryParse(raw.trim());
    if (hours == null || hours <= 0) {
      return _defaultCooldownDuration;
    }
    return Duration(hours: hours);
  }

  @override
  Future<void> saveCooldownDuration(Duration duration) async {
    final hours = duration.inHours;
    if (hours <= 0) {
      throw ArgumentError('Cooldown duration must be positive');
    }
    await _settingsFlagsRepository.saveString(
      _cooldownDurationHoursKey,
      hours.toString(),
    );
  }

  @override
  Future<void> setContactCooldownUntil({
    required String contactId,
    required String cooldownUntil,
  }) async {
    final db = await _database.database;
    final updated = await db.update(
      AppDatabase.contactsTable,
      {
        'cooldown_until': cooldownUntil,
      },
      where: 'id = ?',
      whereArgs: [contactId],
    );
    if (updated == 0) {
      throw StateError('Contact introuvable');
    }
  }

  @override
  Future<String?> fetchContactCooldownUntil(String contactId) async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.contactsTable,
      columns: ['cooldown_until'],
      where: 'id = ?',
      whereArgs: [contactId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['cooldown_until'] as String?;
  }
}
