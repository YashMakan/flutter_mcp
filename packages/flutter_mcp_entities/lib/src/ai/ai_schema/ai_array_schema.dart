part of 'package:flutter_mcp_entities/src/ai/ai_schema.dart';

class AiArraySchema extends AiSchema {
  final AiSchema items;

  const AiArraySchema({required this.items, super.description});

  @override
  Schema toGoogleGenAi() =>
      Schema.array(items: items.toGoogleGenAi(), description: description);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiArraySchema &&
              runtimeType == other.runtimeType &&
              items == other.items &&
              description == other.description;

  @override
  int get hashCode => items.hashCode ^ description.hashCode;
}