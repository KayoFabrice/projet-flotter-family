import 'package:permission_handler/permission_handler.dart';

enum ContactsPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

class ContactsPermissionService {
  Future<ContactsPermissionStatus> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    if (status.isGranted || status.isLimited) {
      return ContactsPermissionStatus.granted;
    }
    if (status.isPermanentlyDenied) {
      return ContactsPermissionStatus.permanentlyDenied;
    }
    return ContactsPermissionStatus.denied;
  }

  Future<bool> openSettings() {
    return openAppSettings();
  }
}
