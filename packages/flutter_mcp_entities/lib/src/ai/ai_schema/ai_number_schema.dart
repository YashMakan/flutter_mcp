part of 'package:flutter_mcp_entities/src/ai/ai_schema.dart';
class AiNumberSchema extends AiSchema {
  const AiNumberSchema({super.description});

  @override
  Schema toGoogleGenAi() => Schema.number(description: description);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiNumberSchema &&
              runtimeType == other.runtimeType &&
              description == other.description;

  @override
  int get hashCode => description.hashCode;
}