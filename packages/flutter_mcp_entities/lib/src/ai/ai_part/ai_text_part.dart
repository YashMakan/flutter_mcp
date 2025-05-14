part of 'package:flutter_mcp_entities/src/ai/ai_part.dart';

/// Represents a text part.
class AiTextPart extends AiPart {
  final String text;
  const AiTextPart(this.text);

  @override
  Part toGoogleGenAi() => TextPart(text);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiTextPart &&
              runtimeType == other.runtimeType &&
              text == other.text;

  @override
  int get hashCode => text.hashCode;
}