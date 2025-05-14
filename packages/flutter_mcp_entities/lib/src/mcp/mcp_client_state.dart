import 'package:flutter/foundation.dart';
import 'package:flutter_mcp_entities/src/mcp/mcp_connection_state.dart';
import 'package:flutter_mcp_entities/src/mcp/mcp_tool_definition.dart';

/// Immutable state representing the overall MCP client system.
/// Managed by the McpRepository implementation and broadcasted.
@immutable
class McpClientState {
  /// Map of server IDs to their connection status.
  final Map<String, McpConnectionStatus> serverStatuses;

  /// Map of server IDs to the list of tools they provide.
  final Map<String, List<McpToolDefinition>> discoveredTools;

  /// Map of server IDs to error messages (if in error state).
  final Map<String, String> serverErrorMessages;

  const McpClientState({
    this.serverStatuses = const {},
    this.discoveredTools = const {},
    this.serverErrorMessages = const {},
  });

  /// Checks if any server is currently connected.
  bool get hasActiveConnections =>
      serverStatuses.values.any((s) => s == McpConnectionStatus.connected);

  /// Gets the count of currently connected servers.
  int get connectedServerCount => serverStatuses.values
      .where((s) => s == McpConnectionStatus.connected)
      .length;

  /// Gets a flattened list of all unique tool names available across connected servers.
  /// Handles potential name collisions by excluding duplicates.
  List<String> get uniqueAvailableToolNames {
    final uniqueNames = <String>{};
    final duplicateNames = <String>{};
    discoveredTools.values.expand((tools) => tools).forEach((tool) {
      if (!uniqueNames.add(tool.name)) {
        duplicateNames.add(tool.name);
      }
    });
    // Remove duplicates from the unique set
    uniqueNames.removeAll(duplicateNames);
    return uniqueNames.toList();
  }

  /// Finds the server ID for a uniquely named tool.
  /// Returns null if the tool name is not found or has duplicates.
  String? getServerIdForTool(String toolName) {
    String? foundServerId;
    int foundCount = 0;
    for (var entry in discoveredTools.entries) {
      if (entry.value.any((tool) => tool.name == toolName)) {
        foundServerId = entry.key;
        foundCount++;
      }
      if (foundCount > 1) return null; // Duplicate found
    }
    return foundCount == 1 ? foundServerId : null;
  }

  McpClientState copyWith({
    Map<String, McpConnectionStatus>? serverStatuses,
    Map<String, List<McpToolDefinition>>? discoveredTools,
    Map<String, String>? serverErrorMessages,
    // Helpers for removing entries safely during updates
    List<String>? removeStatusIds,
    List<String>? removeToolsIds,
    List<String>? removeErrorIds,
  }) {
    final newStatuses = Map<String, McpConnectionStatus>.from(
      serverStatuses ?? this.serverStatuses,
    );
    final newTools = Map<String, List<McpToolDefinition>>.from(
      discoveredTools ?? this.discoveredTools,
    );
    final newErrors = Map<String, String>.from(
      serverErrorMessages ?? this.serverErrorMessages,
    );

    // Apply removals
    removeStatusIds?.forEach(newStatuses.remove);
    removeToolsIds?.forEach(newTools.remove);
    removeErrorIds?.forEach(newErrors.remove);

    return McpClientState(
      serverStatuses: newStatuses,
      discoveredTools: newTools,
      serverErrorMessages: newErrors,
    );
  }
}
