import '../../settings/data/availability_repository.dart';
import '../../settings/data/key_location_repository.dart';
import '../../settings/domain/availability_window.dart';

abstract class RemindersRepository {
  Future<List<String>> fetchKeyLocationLabels();
  Future<List<AvailabilityWindow>> fetchAvailabilityWindows();
}

class RemindersRepositoryImpl implements RemindersRepository {
  RemindersRepositoryImpl({
    required KeyLocationRepository keyLocationRepository,
    required AvailabilityRepository availabilityRepository,
  })  : _keyLocationRepository = keyLocationRepository,
        _availabilityRepository = availabilityRepository;

  final KeyLocationRepository _keyLocationRepository;
  final AvailabilityRepository _availabilityRepository;

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
}
