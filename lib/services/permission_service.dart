import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<Map<Permission, bool>> checkPermissions() async {
    return {
      Permission.camera: await Permission.camera.isGranted,
      Permission.microphone: await Permission.microphone.isGranted,
      Permission.storage: await Permission.storage.isGranted,
      Permission.notification: await Permission.notification.isGranted,
    };
  }

  Future<bool> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.notification,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<bool> shouldShowRationale(Permission permission) async {
    return await permission.shouldShowRequestRationale;
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
