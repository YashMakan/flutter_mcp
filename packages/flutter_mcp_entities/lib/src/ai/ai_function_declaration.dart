import 'package:flutter/foundation.dart';
import 'package:llm_kit/llm_kit.dart';

import 'ai_schema.dart';

@immutable
class AiFunctionDeclaration {
  final String name;
  final String description;
  final AiSchema? parameters;

  const AiFunctionDeclaration({
    required this.name,
    required this.description,
    this.parameters,
  });

  /// Converts to Google Generative AI SDK function declaration
  FunctionDeclaration toGoogleGenAi() =>
      FunctionDeclaration(name, description, parameters?.toGoogleGenAi());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiFunctionDeclaration &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              description == other.description &&
              parameters == other.parameters;

  @override
  int get hashCode =>
      name.hashCode ^ description.hashCode ^ parameters.hashCode;
}