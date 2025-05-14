import 'package:flutter/foundation.dart';
import 'package:llm_kit/llm_kit.dart';

import 'ai_content.dart';

@immutable
class AiCandidate {
  final AiContent content;

  const AiCandidate({required this.content});

  /// Creates from Google Generative AI SDK candidate
  static AiCandidate fromGoogleGenAi(Candidate candidate) =>
      AiCandidate(content: AiContent.fromGoogleGenAi(candidate.content));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiCandidate &&
              runtimeType == other.runtimeType &&
              content == other.content;

  @override
  int get hashCode => content.hashCode;
}