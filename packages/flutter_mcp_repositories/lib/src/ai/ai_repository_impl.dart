import 'dart:async';

import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';
import 'package:flutter_mcp_repositories/src/ai/client/ai_client.dart';
import 'package:flutter_mcp_repositories/src/ai/client/google_generative_ai_client.dart';

/// Implementation of AiRepository using a decoupled AI client.
/// Delegates actual AI interactions to the client implementation.
class AiRepositoryImpl implements AiRepository {
  final SettingsRepository _settingsRepository;

  // Internal state to hold the client and the key it was initialized with
  AiClient? _client;
  String? _cachedApiKey;

  // Constructor now takes SettingsRepository
  AiRepositoryImpl({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository;

  /// Helper to get or initialize the AiClient with the current API key.
  /// Throws an error if the key is missing or initialization fails.
  Future<AiClient> _getClient() async {
    final currentApiKeyUseCase = await _settingsRepository.getApiKey();

    currentApiKeyUseCase.fold((l) => null, (currentApiKey) {
      if (currentApiKey == null || currentApiKey.isEmpty) {
        _client = null; // Ensure client is null if key is invalid
        _cachedApiKey = null;
        throw Exception(
          "AI Service Error: API Key not found in settings.",
        );
      }

      // If client doesn't exist or the key has changed, create a new client
      if (_client == null || _cachedApiKey != currentApiKey) {
        print(
            "AiRepositoryImpl: Initializing AiClient with new/updated API key.");
        _client = GoogleGenerativeAiClient(
            currentApiKey); // This internally calls initialize()
        _cachedApiKey = currentApiKey;
      }
    });

    // Check if the (potentially newly created) client initialized successfully
    if (!_client!.isInitialized) {
      // Keep client null if init failed, so next call tries again
      final error = _client!.initializationError;
      _client = null;
      _cachedApiKey = null;
      throw Exception(
        "AI Service Error: Failed to initialize AI Client. ${error ?? 'Reason unknown.'}",
      );
    }

    return _client!;
  }

  // isInitialized now dynamically checks via _getClient()
  @override
  Future<bool> get isInitialized async {
    try {
      await _getClient(); // Attempt to get/init client
      return true; // Succeeded
    } catch (_) {
      return false; // Failed
    }
  }

  @override
  Stream<AiStreamChunk> sendMessageStream(
    String prompt,
    List<AiContent> history,
  ) async* {
    // Use async* for easier stream error handling
    try {
      final client = await _getClient(); // Get or initialize client

      final userContent = AiContent.user(prompt);
      final contentForAi = [...history, userContent];

      // Delegate to the client, yield results
      await for (final chunk in client.getResponseStream(contentForAi)) {
        yield chunk;
      }
    } catch (e) {
      print("Error initiating AI stream in AiRepositoryImpl: $e");
      // Propagate the error through the stream
      yield* Stream.error(Exception("AI stream failed: ${e.toString()}"));
    }
  }

  @override
  Future<AiResponse> generateContent(
    List<AiContent> historyWithPrompt, {
    List<AiTool>? tools,
  }) async {
    try {
      final client = await _getClient(); // Get or initialize client
      // Delegate to the client
      return await client.getResponse(historyWithPrompt, tools: tools);
    } catch (e) {
      print("Error calling generateContent in AiRepositoryImpl: $e");
      throw Exception("AI content generation failed: ${e.toString()}");
    }
  }
}
