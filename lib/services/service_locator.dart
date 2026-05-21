import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/progress_provider.dart';
import 'api_service.dart';

final getIt = GetIt.instance;

/// Setup Service Locator and Providers
class ServiceLocator {
  /// Initialize all services and providers
  static Future<void> setup() async {
    // Register App State
    final appState = AppState();
    await appState.initialize();
    getIt.registerSingleton<AppState>(appState);

    // Register ApiService
    final apiService = ApiService();
    await apiService.init();
    getIt.registerSingleton<ApiService>(apiService);

    // Register Progress Provider
    getIt.registerSingleton<ProgressProvider>(ProgressProvider());
  }

  /// Get App State instance
  static AppState getAppState() => getIt<AppState>();

  /// Get ApiService instance
  static ApiService getApiService() => getIt<ApiService>();

  /// Get Progress Provider instance
  static ProgressProvider getProgressProvider() => getIt<ProgressProvider>();

  /// Reset all services (for testing or logout)
  static Future<void> reset() async {
    await getIt.reset();
  }
}

/// Provider setup for MaterialApp
List<ChangeNotifierProvider> getProviders() {
  return [
    ChangeNotifierProvider<AppState>(
      create: (_) => ServiceLocator.getAppState(),
    ),
    ChangeNotifierProvider<ProgressProvider>(
      create: (_) => ServiceLocator.getProgressProvider(),
    ),
  ];
}
