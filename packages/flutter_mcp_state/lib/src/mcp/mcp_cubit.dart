import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_usecases/flutter_mcp_usecases.dart';
part 'mcp_state.dart';

class McpCubit extends Cubit<McpState> {
  final GetMcpStateStreamUseCase _getMcpStateStreamUseCase;
  final ConnectMcpServerUseCase _connectMcpServerUseCase;
  final DisconnectMcpServerUseCase _disconnectMcpServerUseCase;
  final DisconnectAllMcpServersUseCase _disconnectAllMcpServersUseCase;
  final GetMcpServerListUseCase _getMcpServerListUseCase; // For sync logic

  StreamSubscription<McpClientState>? _repoStateSubscription;

  McpCubit({
    required GetMcpStateStreamUseCase getMcpStateStreamUseCase,
    required ConnectMcpServerUseCase connectMcpServerUseCase,
    required DisconnectMcpServerUseCase disconnectMcpServerUseCase,
    required DisconnectAllMcpServersUseCase disconnectAllMcpServersUseCase,
    required GetMcpServerListUseCase getMcpServerListUseCase,
  })  : _getMcpStateStreamUseCase = getMcpStateStreamUseCase,
        _connectMcpServerUseCase = connectMcpServerUseCase,
        _disconnectMcpServerUseCase = disconnectMcpServerUseCase,
        _disconnectAllMcpServersUseCase = disconnectAllMcpServersUseCase,
        _getMcpServerListUseCase = getMcpServerListUseCase,
        super(const McpState()); // Initial empty state

  /// Starts listening to the repository's state stream.
  /// Should be called once, e.g., during app initialization or when the Cubit is created.
  Future<void> listenToMcpUpdates() async {
    print("McpCubit: Starting to listen for MCP state updates...");
    final streamEither = await _getMcpStateStreamUseCase();
    streamEither.fold((l) => null, (r) {
      _repoStateSubscription?.cancel();
      _repoStateSubscription = r.listen(
        (mcpClientState) {
          if (!isClosed) {
            print(
              "McpCubit: Received MCP state update - Statuses: ${mcpClientState.serverStatuses.length}, Tools: ${mcpClientState.discoveredTools.length}",
            );
            emit(state.copyWith(mcpClientState: mcpClientState));
          }
        },
        onError: (error) {
          // Handle stream errors - maybe emit an error state or just log
          print("McpCubit: Error in MCP state stream: $error");
          // Optionally emit an error state if you add a status field to McpState
          // emit(state.copyWith(status: McpCubitStatus.error));
        },
        onDone: () {
          print("McpCubit: MCP state stream closed.");
          if (!isClosed) {
            // Decide how to handle stream closure, maybe reset state?
            // emit(const McpState());
          }
        },
      );
    });
  }

  /// Connects/disconnects servers based on the latest settings.
  /// Often called after settings change or on app startup.
  Future<void> syncConnections() async {
    print("McpCubit: Syncing connections...");
    try {
      // Fetch the desired state from settings
      final serverConfigsResult = await _getMcpServerListUseCase.call();
      serverConfigsResult.fold((l) => null, (r) async {
        final List<McpServerConfig> currentServerConfigs = serverConfigsResult
            .getOrElse(() => []); // Assuming direct return or handle Either

        // Get current connection state
        final currentStatuses = state.mcpClientState.serverStatuses;
        final currentlyConnectedOrConnectingIds = currentStatuses.entries
            .where(
              (e) =>
                  e.value == McpConnectionStatus.connected ||
                  e.value == McpConnectionStatus.connecting,
            )
            .map((e) => e.key)
            .toSet();

        final desiredActiveServers =
            currentServerConfigs.where((s) => s.isActive).toList();
        final desiredActiveIds = desiredActiveServers.map((s) => s.id).toSet();
        final knownServerIds = currentServerConfigs.map((s) => s.id).toSet();

        // Determine actions
        final serversToConnect = desiredActiveServers
            .where((config) =>
                !currentlyConnectedOrConnectingIds.contains(config.id))
            .toList();

        final serversToDisconnect = currentlyConnectedOrConnectingIds
            .where((id) =>
                !desiredActiveIds.contains(id) || !knownServerIds.contains(id))
            .toSet();

        // Execute actions
        if (serversToConnect.isNotEmpty || serversToDisconnect.isNotEmpty) {
          print(
              "McpCubit: Sync Actions - Connect: ${serversToConnect.map((s) => s.name)}, Disconnect: $serversToDisconnect");

          // Disconnect first (optional, might prevent issues if reconnecting same server)
          for (final serverId in serversToDisconnect) {
            _disconnectMcpServerUseCase.call(serverId).catchError((e) {
              print(
                  "McpCubit: Error initiating disconnect for $serverId during sync: $e");
            });
          }
          // Allow some time for disconnects before connecting (crude delay)
          await Future.delayed(const Duration(milliseconds: 100));

          // Connect
          for (final config in serversToConnect) {
            final params = ConnectMcpServerParams(
              serverId: config.id,
              command: config.command,
              args: config.args,
              environment: config.customEnvironment,
            );
            _connectMcpServerUseCase.call(params).catchError((e) {
              print(
                  "McpCubit: Error initiating connect for ${config.id} during sync: $e");
              // Error is logged, actual status update will come via the stream listener
            });
          }
        } else {
          print("McpCubit: No sync actions needed.");
        }
      });
    } catch (e) {
      print("McpCubit: Error during syncConnections: ${e.toString()}");
      // Handle error fetching server list
    }
  }

  /// Disconnects all currently connected servers.
  Future<void> disconnectAllServers() async {
    print("McpCubit: Requesting disconnect all servers...");
    try {
      await _disconnectAllMcpServersUseCase.call();
      // State will update via the listener when disconnects complete
    } catch (e) {
      print("McpCubit: Error calling disconnectAll use case: $e");
    }
  }

  /// Explicitly disconnect a single server (useful if needed beyond sync)
  Future<void> disconnectServer(String serverId) async {
    print("McpCubit: Requesting disconnect for server $serverId...");
    try {
      await _disconnectMcpServerUseCase.call(serverId);
    } catch (e) {
      print(
          "McpCubit: Error calling disconnectServer use case for $serverId: $e");
    }
  }

  /// Explicitly connect a single server (useful if needed beyond sync)
  Future<void> connectServer(McpServerConfig config) async {
    print("McpCubit: Requesting connect for server ${config.name}...");
    try {
      final params = ConnectMcpServerParams(
        serverId: config.id,
        command: config.command,
        args: config.args,
        environment: config.customEnvironment,
      );
      await _connectMcpServerUseCase.call(params);
    } catch (e) {
      print(
          "McpCubit: Error calling connectServer use case for ${config.name}: $e");
    }
  }

  @override
  Future<void> close() {
    print("McpCubit: Closing, cancelling subscription.");
    _repoStateSubscription?.cancel();
    // Optionally disconnect all on close? Depends on desired app behavior.
    // disconnectAllServers();
    return super.close();
  }
}
