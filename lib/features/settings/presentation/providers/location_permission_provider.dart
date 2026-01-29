import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/permissions/location_permission_service.dart';

final locationPermissionServiceProvider =
    Provider<LocationPermissionService>((ref) {
  return LocationPermissionService();
});
