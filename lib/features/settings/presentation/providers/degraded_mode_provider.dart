import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/degraded_mode_service.dart';
import 'settings_flags_provider.dart';

final degradedModeServiceProvider = Provider<DegradedModeService>((ref) {
  final repository = ref.read(settingsFlagsRepositoryProvider);
  return DegradedModeService(repository);
});
