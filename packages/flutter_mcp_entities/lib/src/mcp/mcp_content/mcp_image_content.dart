part of 'package:flutter_mcp_entities/src/mcp/mcp_content.dart';

/// Image content.
class McpImageContent extends McpContent {
  /// Base64 encoded image data.
  final String data;

  /// MIME type of the image (e.g., "image/png").
  final String mimeType;

  const McpImageContent({
    required this.data,
    required this.mimeType,
    super.additionalProperties,
  }) : super(type: 'image');
}
