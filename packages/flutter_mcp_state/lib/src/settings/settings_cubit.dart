import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_usecases/flutter_mcp_usecases.dart';
import 'package:uuid/uuid.dart';

part 'settings_state.dart';

const _uuid = Uuid();

class SettingsCubit extends Cubit<SettingsState> {
  final GetApiKeyUseCase _getApiKeyUseCase;
  final SaveApiKeyUseCase _saveApiKeyUseCase;
  final ClearApiKeyUseCase _clearApiKeyUseCase;
  final GetMcpServerListUseCase _getMcpServerListUseCase;
  final AddMcpServerUseCase _addMcpServerUseCase;
  final UpdateMcpServerUseCase _updateMcpServerUseCase;
  final DeleteMcpServerUseCase _deleteMcpServerUseCase;
  final ToggleMcpServerActiveUseCase _toggleMcpServerActiveUseCase;

  SettingsCubit({
    required GetApiKeyUseCase getApiKeyUseCase,
    required SaveApiKeyUseCase saveApiKeyUseCase,
    required ClearApiKeyUseCase clearApiKeyUseCase,
    required GetMcpServerListUseCase getMcpServerListUseCase,
    required AddMcpServerUseCase addMcpServerUseCase,
    required UpdateMcpServerUseCase updateMcpServerUseCase,
    required DeleteMcpServerUseCase deleteMcpServerUseCase,
    required ToggleMcpServerActiveUseCase toggleMcpServerActiveUseCase,
  })  : _getApiKeyUseCase = getApiKeyUseCase,
        _saveApiKeyUseCase = saveApiKeyUseCase,
        _clearApiKeyUseCase = clearApiKeyUseCase,
        _getMcpServerListUseCase = getMcpServerListUseCase,
        _addMcpServerUseCase = addMcpServerUseCase,
        _updateMcpServerUseCase = updateMcpServerUseCase,
        _deleteMcpServerUseCase = deleteMcpServerUseCase,
        _toggleMcpServerActiveUseCase = toggleMcpServerActiveUseCase,
        super(const SettingsState());

  Future<void> loadInitialSettings() async {
    emit(state.copyWith(
        status: SettingsStatus.loading, clearErrorMessage: true));

    // Fetch both concurrently
    final results = await Future.wait([
      _getApiKeyUseCase.call(),
      _getMcpServerListUseCase.call(),
    ]);

    final apiKeyResult = results[0] as Either<Failure, String?>;
    final serverListResult =
        results[1] as Either<Failure, List<McpServerConfig>>;

    // Check for failures
    Failure? firstFailure;
    apiKeyResult.fold((f) => firstFailure ??= f, (_) => null);
    serverListResult.fold((f) => firstFailure ??= f, (_) => null);

    if (firstFailure != null) {
      print("Error loading initial settings: ${firstFailure?.message}");
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: "Failed to load settings: ${firstFailure?.message}",
      ));
    } else {
      // Both succeeded, extract values (use fold again or assume right)
      print(state.serverList);
      emit(state.copyWith(
        status: SettingsStatus.loaded,
        apiKey: apiKeyResult.getOrElse(() => null),
        serverList: List.from(serverListResult.getOrElse(() => [])),
      ));
      print("Initial settings loaded successfully.");
      print(state.serverList);
    }
  }

  Future<void> saveApiKey(String apiKey) async {
    if (apiKey.trim().isEmpty) {
      // Emit error directly for validation failure
      emit(state.copyWith(
          status: SettingsStatus.error,
          errorMessage: 'API Key cannot be empty.'));
      return;
    }
    emit(state.copyWith(
        status: SettingsStatus.loading, clearErrorMessage: true));
    final result = await _saveApiKeyUseCase.call(apiKey.trim());

    result.fold(
      (failure) {
        print("Error saving API key: ${failure.message}");
        emit(state.copyWith(
          status: SettingsStatus.error,
          errorMessage: "Failed to save API key: ${failure.message}",
        ));
      },
      (_) {
        // On success (Right contains Unit)
        emit(state.copyWith(
            status: SettingsStatus.loaded, apiKey: apiKey.trim()));
        print("API key saved successfully.");
      },
    );
  }

  Future<void> clearApiKey() async {
    emit(state.copyWith(
        status: SettingsStatus.loading, clearErrorMessage: true));
    final result = await _clearApiKeyUseCase.call();

    result.fold(
      (failure) {
        print("Error clearing API key: ${failure.message}");
        emit(state.copyWith(
          status: SettingsStatus.error,
          errorMessage: "Failed to clear API key: ${failure.message}",
        ));
      },
      (_) {
        // On success
        emit(state.copyWith(status: SettingsStatus.loaded, clearApiKey: true));
        print("API key cleared successfully.");
      },
    );
  }

  // Helper to refresh the server list and update state
  Future<void> _refreshServerListAndEmitState() async {
    final listResult = await _getMcpServerListUseCase.call();
    listResult.fold((failure) {
      print(
          "Error refreshing server list after operation: ${failure.message}");
      // Keep loading state, but show error from refresh failure
      emit(state.copyWith(
          status: SettingsStatus.error,
          errorMessage:
              "Operation succeeded, but failed to refresh list: ${failure.message}"));
    }, (updatedList) {
      emit(state.copyWith(
          status: SettingsStatus.loaded, serverList: updatedList));
      print("Server list action successful, list refreshed.");
    });
  }

  Future<void> addMcpServer(String name, String command, String args,
      Map<String, String> envVars) async {
    emit(state.copyWith(
        status: SettingsStatus.loading, clearErrorMessage: true));
    final newServer = McpServerConfig(
      id: _uuid.v4(),
      name: name.trim(),
      command: command.trim(),
      args: args.trim(),
      isActive: false,
      // Default inactive
      customEnvironment: envVars,
    );
    final result = await _addMcpServerUseCase.call(newServer);

    result.fold(
      (failure) {
        print("Error adding server: ${failure.message}");
        emit(state.copyWith(
          status: SettingsStatus.error,
          errorMessage: "Failed to add server: ${failure.message}",
        ));
      },
      (_) async {
        // On success
        // Refresh list to show the newly added server
        await _refreshServerListAndEmitState();
      },
    );
  }

  Future<void> updateMcpServer(McpServerConfig server) async {
    emit(state.copyWith(
        status: SettingsStatus.loading, clearErrorMessage: true));
    final result = await _updateMcpServerUseCase.call(server);

    result.fold(
      (failure) {
        print("Error updating server: ${failure.message}");
        emit(state.copyWith(
          status: SettingsStatus.error,
          errorMessage: "Failed to update server: ${failure.message}",
        ));
      },
      (_) async {
        // On success
        await _refreshServerListAndEmitState();
      },
    );
  }

  Future<void> deleteMcpServer(String serverId) async {
    emit(state.copyWith(
        status: SettingsStatus.loading, clearErrorMessage: true));
    final result = await _deleteMcpServerUseCase.call(serverId);

    result.fold(
      (failure) {
        print("Error deleting server: ${failure.message}");
        emit(state.copyWith(
          status: SettingsStatus.error,
          errorMessage: "Failed to delete server: ${failure.message}",
        ));
      },
      (_) async {
        // On success
        await _refreshServerListAndEmitState();
      },
    );
  }

  Future<void> toggleMcpServerActive(String serverId, bool isActive) async {
    // Don't emit loading for toggle, but clear previous error
    emit(state.copyWith(clearErrorMessage: true));
    final params =
        ToggleMcpServerActiveParams(serverId: serverId, isActive: isActive);
    final result = await _toggleMcpServerActiveUseCase.call(params);

    result.fold(
      (failure) async {
        print("Error toggling server active state: ${failure.message}");
        // Show error, list might be out of sync until reload
        emit(state.copyWith(
          status: SettingsStatus.error, // Set error status here
          errorMessage: "Failed to toggle server state: ${failure.message}",
        ));
        // Attempt to reload the list to ensure consistency after showing error
        // Consider delaying this slightly if needed
        await loadInitialSettings();
      },
      (_) async {
        // On success
        // Refresh list to show updated toggle state
        await _refreshServerListAndEmitState();
      },
    );
  }
}
