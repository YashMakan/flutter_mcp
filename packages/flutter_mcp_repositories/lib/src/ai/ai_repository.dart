import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';

abstract class AiRepository {
  /// Checks if the AI service is initialized and ready.
  Future<bool> get isInitialized;

  // Removed: GenerativeModel? get generativeModel; - Implementation detail

  /// Sends a prompt and history to the AI model and returns a stream of response chunks.
  Stream<AiStreamChunk> sendMessageStream(
    String prompt,
    List<AiContent> history, // Use domain entity
  );

  /// Sends content (history + prompt) and optional tools to the AI model for a single response.
  Future<AiResponse> generateContent(
    // Use domain entity
    List<AiContent> historyWithPrompt, {
    // Use domain entity
    List<AiTool>? tools, // Use domain entity
  });
}
