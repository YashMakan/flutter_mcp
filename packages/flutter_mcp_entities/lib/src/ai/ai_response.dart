import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:llm_kit/llm_kit.dart';

import 'ai_candidate.dart';
import 'ai_content.dart';

@immutable
class AiResponse {
  final List<AiCandidate> candidates;

  const AiResponse({required this.candidates});

  /// Creates from Google Generative AI SDK response
  static AiResponse fromGoogleGenAi(GenerateContentResponse response) {
    final domainCandidates =
    response.candidates.map(AiCandidate.fromGoogleGenAi).toList();
    return AiResponse(candidates: domainCandidates);
  }

  /// Gets the content from the first candidate, if available.
  AiContent? get firstCandidateContent => candidates.firstOrNull?.content;

  /// Gets the text from the first candidate's content, if available.
  String? get text => firstCandidateContent?.text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiResponse &&
              runtimeType == other.runtimeType &&
              const ListEquality().equals(candidates, other.candidates);

  @override
  int get hashCode => const ListEquality().hash(candidates);
}