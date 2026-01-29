import 'package:permission_handler/permission_handler.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

class LocationPermissionService {
  Future<LocationPermissionStatus> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted || status.isLimited) {
      return LocationPermissionStatus.granted;
    }
    if (status.isPermanentlyDenied) {
      return LocationPermissionStatus.permanentlyDenied;
    }
    return LocationPermissionStatus.denied;
  }

  Future<bool> openSettings() {
    return openAppSettings();
  }
}
