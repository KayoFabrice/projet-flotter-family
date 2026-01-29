import '../data/availability_repository.dart';
import 'availability_window.dart';

class AvailabilityService {
  AvailabilityService(this._repository);

  final AvailabilityRepository _repository;

  Future<List<AvailabilityWindow>> loadWindows() {
    return _repository.fetchWindows();
  }

  Future<void> saveWindows(List<AvailabilityWindow> windows) async {
    _validate(windows);
    await _repository.saveWindows(windows);
  }

  void _validate(List<AvailabilityWindow> windows) {
    if (windows.isEmpty) {
      throw ArgumentError('Au moins une plage horaire est requise.');
    }
    final sorted = [...windows]..sort((a, b) => a.startMinute.compareTo(b.startMinute));
    for (final window in sorted) {
      if (window.startMinute < 0 ||
          window.endMinute > 24 * 60 ||
          window.startMinute >= window.endMinute) {
        throw ArgumentError('Plage horaire invalide.');
      }
    }
    for (var i = 0; i < sorted.length - 1; i++) {
      final current = sorted[i];
      final next = sorted[i + 1];
      if (current.endMinute > next.startMinute) {
        throw ArgumentError('Plages horaires qui se chevauchent.');
      }
    }
  }
}
