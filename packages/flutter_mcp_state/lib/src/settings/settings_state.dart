part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, loaded, error }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final String? apiKey;
  final List<McpServerConfig> serverList;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.apiKey,
    this.serverList = const [],
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    String? apiKey,
    bool clearApiKey = false, // Helper to explicitly clear
    List<McpServerConfig>? serverList,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SettingsState(
      status: status ?? this.status,
      apiKey: clearApiKey ? null : apiKey ?? this.apiKey,
      serverList: serverList ?? this.serverList,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, apiKey, serverList, errorMessage];
}