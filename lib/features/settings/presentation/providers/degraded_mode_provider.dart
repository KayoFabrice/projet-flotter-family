import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/settings_flags_repository.dart';
import '../../domain/degraded_mode_service.dart';

final settingsFlagsRepositoryProvider = Provider<SettingsFlagsRepository>((ref) {
  return SettingsFlagsRepositoryImpl(AppDatabase.instance);
});

final degradedModeServiceProvider = Provider<DegradedModeService>((ref) {
  final repository = ref.read(settingsFlagsRepositoryProvider);
  return DegradedModeService(repository);
});
