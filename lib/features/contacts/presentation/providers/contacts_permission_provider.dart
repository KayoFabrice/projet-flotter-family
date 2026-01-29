import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/permissions/contacts_permission_service.dart';

final contactsPermissionServiceProvider = Provider<ContactsPermissionService>((ref) {
  return ContactsPermissionService();
});
