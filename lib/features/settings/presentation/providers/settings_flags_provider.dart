import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/settings_flags_repository.dart';

final settingsFlagsRepositoryProvider = Provider<SettingsFlagsRepository>((
  ref,
) {
  return SettingsFlagsRepositoryImpl(AppDatabase.instance);
});
