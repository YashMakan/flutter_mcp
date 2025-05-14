import 'package:flutter/foundation.dart';
import 'package:llm_kit/llm_kit.dart';

/// Represents a chunk of data received from a streaming AI call.
@immutable
class AiStreamChunk {
  final String textDelta;

  const AiStreamChunk({required this.textDelta});

  static AiStreamChunk fromGoogleGenAi(GenerateContentResponse chunk) =>
      AiStreamChunk(textDelta: chunk.text ?? "");

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiStreamChunk &&
              runtimeType == other.runtimeType &&
              textDelta == other.textDelta;

  @override
  int get hashCode => textDelta.hashCode;
}