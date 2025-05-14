part of 'package:flutter_mcp_entities/src/ai/ai_schema.dart';

class AiStringSchema extends AiSchema {
  final List<String>? enumValues;

  const AiStringSchema({this.enumValues, super.description});

  @override
  Schema toGoogleGenAi() {
    return (enumValues != null && enumValues!.isNotEmpty)
        ? Schema.enumString(enumValues: enumValues!, description: description)
        : Schema.string(description: description);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiStringSchema &&
              runtimeType == other.runtimeType &&
              const ListEquality().equals(enumValues, other.enumValues) &&
              description == other.description;

  @override
  int get hashCode =>
      const ListEquality().hash(enumValues) ^ description.hashCode;
}