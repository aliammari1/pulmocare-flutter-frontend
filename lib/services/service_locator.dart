import 'package:get_it/get_it.dart';
import 'report_service.dart';
import 'notification_service.dart';
import 'backup_service.dart';
import 'analytics_service.dart';
import 'media_service.dart';
import 'permission_service.dart';
import 'cache_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<CacheService>(CacheService());
  getIt.registerSingleton<ReportService>(ReportService());
  getIt.registerSingleton<NotificationService>(NotificationService());
  getIt.registerSingleton<BackupService>(BackupService());
  getIt.registerSingleton<AnalyticsService>(AnalyticsService());
  getIt.registerSingleton<MediaService>(MediaService());
  getIt.registerSingleton<PermissionService>(PermissionService());
  await getIt<NotificationService>().initialize();
  await getIt<PermissionService>().requestAllPermissions();
}
