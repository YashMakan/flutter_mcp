part of 'package:flutter_mcp_entities/src/ai/ai_schema.dart';

class AiObjectSchema extends AiSchema {
  final Map<String, AiSchema> properties;
  final List<String>? requiredProperties;

  const AiObjectSchema({
    required this.properties,
    this.requiredProperties,
    super.description,
  });

  @override
  Schema toGoogleGenAi() {
    return Schema.object(
      properties: properties.map((k, v) => MapEntry(k, v.toGoogleGenAi())),
      requiredProperties: requiredProperties,
      description: description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiObjectSchema &&
              runtimeType == other.runtimeType &&
              const MapEquality().equals(properties, other.properties) &&
              const ListEquality().equals(
                requiredProperties,
                other.requiredProperties,
              ) &&
              description == other.description;

  @override
  int get hashCode =>
      const MapEquality().hash(properties) ^
      const ListEquality().hash(requiredProperties) ^
      description.hashCode;
}