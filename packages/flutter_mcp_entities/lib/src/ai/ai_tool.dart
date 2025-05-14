import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:llm_kit/llm_kit.dart';

import 'ai_function_declaration.dart';

@immutable
class AiTool {
  final List<AiFunctionDeclaration> functionDeclarations;

  const AiTool({required this.functionDeclarations});

  /// Converts to Google Generative AI SDK tool
  Tool toGoogleGenAi() {
    final declarations =
    functionDeclarations.map((decl) => decl.toGoogleGenAi()).toList();
    return Tool(functionDeclarations: declarations);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiTool &&
              runtimeType == other.runtimeType &&
              const ListEquality().equals(
                functionDeclarations,
                other.functionDeclarations,
              );

  @override
  int get hashCode => const ListEquality().hash(functionDeclarations);
}