part of 'package:flutter_mcp_entities/src/mcp/mcp_content.dart';

/// Text content.
class McpTextContent extends McpContent {
  /// The text string.
  final String text;

  const McpTextContent({required this.text, super.additionalProperties})
      : super(type: 'text');
}