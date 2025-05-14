import 'package:flutter/foundation.dart';

/// Represents the definition of a tool discovered via MCP.
/// The schema is kept as a raw Map, as defined by the MCP server.
@immutable
class McpToolDefinition {
  final String name;
  final String? description;
  final Map<String, dynamic> inputSchema; // Raw JSON schema as Map

  const McpToolDefinition({
    required this.name,
    this.description,
    required this.inputSchema,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is McpToolDefinition &&
              runtimeType == other.runtimeType &&
              name == other.name; // Simple equality based on name for now

  @override
  int get hashCode => name.hashCode;
}