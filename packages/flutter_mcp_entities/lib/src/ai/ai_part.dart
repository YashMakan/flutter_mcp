import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:llm_kit/llm_kit.dart';

part 'ai_part/ai_text_part.dart';
part 'ai_part/ai_function_call_part.dart';
part 'ai_part/ai_function_response_part.dart';

@immutable
sealed class AiPart {
  const AiPart();

  /// Converts to Google Generative AI SDK part
  Part toGoogleGenAi();

  /// Creates from Google Generative AI SDK part
  static AiPart fromGoogleGenAi(Part part) {
    return switch (part) {
      TextPart p => AiTextPart(p.text),
      FunctionCall p => AiFunctionCallPart(name: p.name, args: p.args),
      FunctionResponse p => AiFunctionResponsePart(
          name: p.name,
          response: p.response ?? {},
        ),
      _ => AiTextPart("[Unsupported Part Type: ${part.runtimeType}]"),
    };
  }
}
