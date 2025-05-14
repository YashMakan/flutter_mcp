import 'package:flutter/foundation.dart';
import 'package:flutter_mcp_entities/src/mcp/resource_contents.dart';

part 'mcp_content/mcp_embedded_resource.dart';
part 'mcp_content/mcp_image_content.dart';
part 'mcp_content/mcp_text_content.dart';
part 'mcp_content/mcp_unknown_content.dart';

/// Base class for structured content returned by MCP tools.
@immutable
sealed class McpContent {
  /// The type of the content part (e.g., 'text', 'image').
  final String type;

  /// Additional properties not part of the standard structure.
  final Map<String, dynamic> additionalProperties;

  const McpContent({required this.type, this.additionalProperties = const {}});

  /// Creates a specific McpContent instance from a JSON map.
  /// This factory determines the subtype based on the 'type' field.
  factory McpContent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    // Create a mutable copy to remove processed keys
    final Map<String, dynamic> remainingProperties = Map.from(json);
    remainingProperties.remove('type'); // Remove type after reading

    try {
      // Add try-catch for robustness during parsing
      switch (type) {
        case 'text':
          remainingProperties.remove('text'); // Remove known keys
          return McpTextContent(
            text: json['text'] as String,
            additionalProperties: remainingProperties,
          );
        case 'image':
          remainingProperties.remove('data');
          remainingProperties.remove('mimeType');
          return McpImageContent(
            data: json['data'] as String,
            mimeType: json['mimeType'] as String,
            additionalProperties: remainingProperties,
          );
        case 'resource':
          remainingProperties.remove('resource');
          return McpEmbeddedResource(
            resource: ResourceContents.fromJson(
              json['resource'] as Map<String, dynamic>,
            ),
            additionalProperties: remainingProperties,
          );
        default:
          // Keep all properties for unknown types
          return McpUnknownContent(
            type: type ?? 'unknown',
            additionalProperties: remainingProperties, // Pass the rest
          );
      }
    } catch (e, stackTrace) {
      debugPrint("Error parsing McpContent (type: $type): $e\n$stackTrace");
      // Fallback to UnknownContent on parsing error
      return McpUnknownContent(
        type: type ?? 'error',
        additionalProperties: {'error': e.toString(), ...remainingProperties},
      );
    }
  }

  /// Converts this McpContent instance back to a JSON map.
  Map<String, dynamic> toJson() => {
        'type': type,
        // Add type-specific properties
        ...switch (this) {
          McpTextContent c => {'text': c.text},
          McpImageContent c => {'data': c.data, 'mimeType': c.mimeType},
          McpEmbeddedResource c => {'resource': c.resource.toJson()},
          McpUnknownContent _ =>
            {}, // Unknown types only have additional props stored
        },
        // Add any additional properties
        ...additionalProperties,
      };
}
