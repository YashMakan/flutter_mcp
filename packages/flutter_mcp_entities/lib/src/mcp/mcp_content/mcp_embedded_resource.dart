part of 'package:flutter_mcp_entities/src/mcp/mcp_content.dart';

/// Content embedding a resource.
class McpEmbeddedResource extends McpContent {
  /// The embedded resource contents.
  final ResourceContents resource;

  const McpEmbeddedResource({
    required this.resource,
    super.additionalProperties,
  }) : super(type: 'resource');
}
