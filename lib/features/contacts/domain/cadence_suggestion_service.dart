import 'cadence_service.dart';
import 'contact_circle.dart';
import '../../settings/domain/cadence_update_service.dart';

class CadenceSuggestionSnapshot {
  const CadenceSuggestionSnapshot({
    required this.cadences,
    required this.shouldDelaySuggestions,
  });

  final Map<ContactCircle, int> cadences;
  final bool shouldDelaySuggestions;
}

class CadenceSuggestionService {
  CadenceSuggestionService(
    this._cadenceService,
    this._updateService, {
    Duration minDelay = const Duration(hours: 1),
  }) : _minDelay = minDelay;

  final CadenceService _cadenceService;
  final CadenceUpdateService _updateService;
  final Duration _minDelay;

  Future<CadenceSuggestionSnapshot> loadSnapshot(
    List<ContactCircle> circles,
  ) async {
    final cadences = await _cadenceService.loadCadencesForCircles(circles);
    final shouldDelay = await _updateService.shouldDelaySuggestions(_minDelay);
    return CadenceSuggestionSnapshot(
      cadences: {
        for (final cadence in cadences) cadence.circle: cadence.cadenceDays,
      },
      shouldDelaySuggestions: shouldDelay,
    );
  }
}
