import 'package:flutter/foundation.dart';
import 'package:flutter_mcp_entities/src/mcp/mcp_content.dart';


@immutable
class McpToolResult {
  /// A list of content parts returned by the tool.
  final List<McpContent> content;

  const McpToolResult({required this.content});

  /// Convenience getter for the first text content part, if any.
  String? get firstText {
    final textContent = content.whereType<McpTextContent>().firstOrNull;
    return textContent?.text;
  }

  /// Convenience getter for the first image content part, if any.
  McpImageContent? get firstImage {
    return content.whereType<McpImageContent>().firstOrNull;
  }

  /// Convenience getter for the first embedded resource part, if any.
  McpEmbeddedResource? get firstResource {
    return content.whereType<McpEmbeddedResource>().firstOrNull;
  }

  /// Checks if the result contains any content parts.
  bool get isEmpty => content.isEmpty;

  /// Checks if the result contains only a single text part.
  bool get isSingleText =>
      content.length == 1 && content.first is McpTextContent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is McpToolResult &&
              runtimeType == other.runtimeType &&
              listEquals(content, other.content); // Compare lists

  @override
  int get hashCode => Object.hashAll(content); // Hash based on list content
}