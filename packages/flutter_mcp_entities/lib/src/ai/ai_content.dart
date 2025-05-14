import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:llm_kit/llm_kit.dart';

import 'ai_part.dart';



@immutable
class AiContent {
  final String role;
  final List<AiPart> parts;

  const AiContent({required this.role, required this.parts});

  /// Convenience constructor for simple text content from user.
  factory AiContent.user(String text) =>
      AiContent(role: 'user', parts: [AiTextPart(text)]);

  /// Convenience constructor for simple text content from model.
  factory AiContent.model(String text) =>
      AiContent(role: 'model', parts: [AiTextPart(text)]);

  /// Convenience constructor for a tool response.
  factory AiContent.toolResponse(
      String toolName,
      Map<String, dynamic> responseData,
      ) => AiContent(
    role: 'tool',
    parts: [AiFunctionResponsePart(name: toolName, response: responseData)],
  );

  /// Converts to Google Generative AI SDK content
  Content toGoogleGenAi() {
    final sdkParts = parts.map((part) => part.toGoogleGenAi()).toList();
    return Content(role, sdkParts);
  }

  /// Creates from Google Generative AI SDK content
  static AiContent fromGoogleGenAi(Content content) {
    final domainParts = content.parts.map(AiPart.fromGoogleGenAi).toList();
    return AiContent(role: content.role ?? 'unknown', parts: domainParts);
  }

  /// Extracts the text from all TextParts, joined together.
  String get text => parts.whereType<AiTextPart>().map((p) => p.text).join();

  /// Checks if this content has a function call part and returns the first one if it exists
  AiFunctionCallPart? get functionCall =>
      parts.whereType<AiFunctionCallPart>().firstOrNull;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiContent &&
              runtimeType == other.runtimeType &&
              role == other.role &&
              const ListEquality().equals(parts, other.parts);

  @override
  int get hashCode => role.hashCode ^ const ListEquality().hash(parts);
}