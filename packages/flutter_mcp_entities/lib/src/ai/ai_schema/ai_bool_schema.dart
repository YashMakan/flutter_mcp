part of 'package:flutter_mcp_entities/src/ai/ai_schema.dart';
class AiBooleanSchema extends AiSchema {
  const AiBooleanSchema({super.description});

  @override
  Schema toGoogleGenAi() => Schema.boolean(description: description);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiBooleanSchema &&
              runtimeType == other.runtimeType &&
              description == other.description;

  @override
  int get hashCode => description.hashCode;
}