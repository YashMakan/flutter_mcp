import 'package:flutter_mcp_datasources/flutter_mcp_datasources.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';
import 'package:flutter_mcp_usecases/flutter_mcp_usecases.dart';
import 'package:flutter_mcp_state/flutter_mcp_state.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance; // Service Locator instance

Future<void> initDi() async {

  sl.registerLazySingleton(() => SettingsCubit(
        getApiKeyUseCase: sl(),
        saveApiKeyUseCase: sl(),
        clearApiKeyUseCase: sl(),
        getMcpServerListUseCase: sl(),
        addMcpServerUseCase: sl(),
        updateMcpServerUseCase: sl(),
        deleteMcpServerUseCase: sl(),
        toggleMcpServerActiveUseCase: sl(),
      ));
  sl.registerLazySingleton(() => McpCubit(
      getMcpStateStreamUseCase: sl(),
      connectMcpServerUseCase: sl(),
      disconnectMcpServerUseCase: sl(),
      disconnectAllMcpServersUseCase: sl(),
      getMcpServerListUseCase: sl()));
  sl.registerLazySingleton(() => ChatCubit(
      sendMessageUseCase: sl(),
      getApiKeyUseCase: sl(),
      mcpCubit: sl(),
      settingsCubit: sl()));

  // Use Cases (Lazy Singletons - created once when first requested)
  // Settings
  sl.registerLazySingleton(() => GetApiKeyUseCase(sl()));
  sl.registerLazySingleton(() => SaveApiKeyUseCase(sl()));
  sl.registerLazySingleton(() => ClearApiKeyUseCase(sl()));
  sl.registerLazySingleton(() => GetMcpServerListUseCase(sl()));
  sl.registerLazySingleton(() => AddMcpServerUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMcpServerUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMcpServerUseCase(sl()));
  sl.registerLazySingleton(() => ToggleMcpServerActiveUseCase(sl()));

  // MCP
  sl.registerLazySingleton(() => GetMcpStateStreamUseCase(sl()));
  sl.registerLazySingleton(() => ConnectMcpServerUseCase(sl()));
  sl.registerLazySingleton(() => DisconnectMcpServerUseCase(sl()));
  sl.registerLazySingleton(() => DisconnectAllMcpServersUseCase(sl()));
  sl.registerLazySingleton(() => ExecuteMcpToolUseCase(sl()));

  // Chat
  sl.registerLazySingleton(
      () => SendMessageUseCase(sl(), sl())); // Needs AI, MCP

  // Repositories (Lazy Singletons)
  sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(localDataSource: sl()));
  sl.registerLazySingleton<McpRepository>(() => McpRepositoryImpl());
  sl.registerLazySingleton<AiRepository>(
      () => AiRepositoryImpl(settingsRepository: sl()));

  // Data Sources (Lazy Singletons)
  sl.registerLazySingleton<SettingsLocalDataSource>(
      () => SettingsLocalDataSourceImpl(sharedPreferences: sl()));

  // External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
