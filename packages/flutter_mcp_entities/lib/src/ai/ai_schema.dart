import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:llm_kit/llm_kit.dart';

part 'ai_schema/ai_array_schema.dart';
part 'ai_schema/ai_bool_schema.dart';
part 'ai_schema/ai_number_schema.dart';
part 'ai_schema/ai_object_schema.dart';
part 'ai_schema/ai_string_schema.dart';

/// Base class for schema definitions used in function declarations.
@immutable
sealed class AiSchema {
  final String? description;
  const AiSchema({this.description});

  /// Converts the domain schema to a Google Generative AI SDK schema
  Schema toGoogleGenAi();

  /// Converts a JSON Schema map to an AiSchema instance
  static AiSchema? fromSchemaMap(Map<String, dynamic>? schemaMap) {
    if (schemaMap == null) return null;

    final type = schemaMap['type'] as String?;
    final description = schemaMap['description'] as String?;

    try {
      switch (type) {
        case 'object':
          final properties =
              schemaMap['properties'] as Map<String, dynamic>? ?? {};
          final requiredList =
          (schemaMap['required'] as List<dynamic>?)?.cast<String>();
          final aiProperties = properties.map((key, value) {
            if (value is Map<String, dynamic>) {
              return MapEntry(key, fromSchemaMap(value)!);
            } else {
              throw FormatException(
                "Invalid property value type for key '$key'",
              );
            }
          });

          return AiObjectSchema(
            properties: aiProperties,
            requiredProperties: requiredList,
            description: description,
          );
        case 'string':
          final enumValues =
          (schemaMap['enum'] as List<dynamic>?)?.cast<String>();
          return AiStringSchema(
            enumValues: enumValues,
            description: description,
          );
        case 'number':
        case 'integer':
          return AiNumberSchema(description: description);
        case 'boolean':
          return AiBooleanSchema(description: description);
        case 'array':
          final items = schemaMap['items'] as Map<String, dynamic>?;
          if (items == null) {
            throw FormatException("Array schema missing 'items'.");
          }
          final aiItems = fromSchemaMap(items);
          if (aiItems == null) {
            throw FormatException("Failed to translate array 'items'.");
          }
          return AiArraySchema(items: aiItems, description: description);
        default:
          debugPrint(
            "Unsupported schema type encountered during translation: $type",
          );
          return null;
      }
    } catch (e) {
      debugPrint("Error translating schema fragment (type: $type): $e");
      return null;
    }
  }
}