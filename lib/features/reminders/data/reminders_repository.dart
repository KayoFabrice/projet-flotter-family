import '../../settings/data/availability_repository.dart';
import '../../settings/data/key_location_repository.dart';
import '../../settings/data/settings_flags_repository.dart';
import '../domain/rest_window.dart';
import 'rest_window_repository.dart';
import '../../settings/domain/availability_window.dart';

abstract class RemindersRepository {
  Future<List<String>> fetchKeyLocationLabels();
  Future<List<AvailabilityWindow>> fetchAvailabilityWindows();
  Future<List<RestWindow>> fetchRestWindows();
}

class RemindersRepositoryImpl implements RemindersRepository {
  RemindersRepositoryImpl({
    required KeyLocationRepository keyLocationRepository,
    required AvailabilityRepository availabilityRepository,
    required RestWindowRepository restWindowRepository,
    required SettingsFlagsRepository settingsFlagsRepository,
  })  : _keyLocationRepository = keyLocationRepository,
        _availabilityRepository = availabilityRepository,
        _restWindowRepository = restWindowRepository,
        _settingsFlagsRepository = settingsFlagsRepository;

  final KeyLocationRepository _keyLocationRepository;
  final AvailabilityRepository _availabilityRepository;
  final RestWindowRepository _restWindowRepository;
  final SettingsFlagsRepository _settingsFlagsRepository;

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
}
