import 'eligibility_result.dart';

class EligibilityLogService {
  final List<EligibilityLogEntry> _entries = [];

  List<EligibilityLogEntry> get entries => List.unmodifiable(_entries);

  EligibilityLogEntry? get latest => _entries.isEmpty ? null : _entries.last;

  void record(EligibilityResult result) {
    _entries.add(
      EligibilityLogEntry(
        result: result,
        recordedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
