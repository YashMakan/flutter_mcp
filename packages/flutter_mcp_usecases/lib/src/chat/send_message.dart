import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

// --- Parameters ---
class SendMessageParams {
  final String prompt;
  final List<AiContent> history;

  const SendMessageParams({required this.prompt, required this.history});
}

class SendMessageUseCase
    implements UseCase<Stream<SendMessageUpdate>, SendMessageParams> {
  final AiRepository _aiRepository;
  final McpRepository _mcpRepository;

  SendMessageUseCase(
    this._aiRepository,
    this._mcpRepository,
  );

  @override
  Future<Either<Failure, Stream<SendMessageUpdate>>> call(
      SendMessageParams params) async {
    final controller = StreamController<SendMessageUpdate>();

    _executeSendMessage(params, controller);

    return right(controller.stream);
  }

  // Internal helper to manage the async logic and controller
  Future<void> _executeSendMessage(SendMessageParams params,
      StreamController<SendMessageUpdate> controller) async {
    try {
      // 1. Initial Check: Ensure AI Repo is ready by checking API KEY
      final isAiInitialized = await _aiRepository.isInitialized;
      if (!isAiInitialized) {
        throw Exception(
            "AI Service not available (check API Key or initialization).");
      }

      final userMessageText = params.prompt.trim();
      final userMessageForHistory = AiContent.user(userMessageText);
      final historyForApi = List<AiContent>.from(params.history);

      // 2. Decide Path: Check MCP state
      final mcpState =
          _mcpRepository.currentMcpState; // Get current state synchronously
      print("mcpState.discoveredTools::${mcpState.discoveredTools}");
      print("mcpState.hasActiveConnections::${mcpState.hasActiveConnections}");
      final bool useMcp = mcpState.hasActiveConnections &&
          mcpState.discoveredTools.values.any((list) => list.isNotEmpty);

      if (useMcp) {
        // --- MCP Orchestration Path ---
        print("SendMessageUseCase: Orchestrating query via MCP...");
        await _orchestrateMcpQuery(
          userMessageText: userMessageText,
          historyForApi: historyForApi,
          userMessageForHistory: userMessageForHistory,
          mcpState: mcpState,
          controller: controller,
        );
      } else {
        // --- Direct AI Streaming Path ---
        print("SendMessageUseCase: Processing query via Direct AI Stream...");
        await _streamDirectAiResponse(
          userMessageText: userMessageText,
          historyForApi: historyForApi,
          userMessageForHistory: userMessageForHistory,
          controller: controller,
        );
      }

      // If execution reaches here without errors, close the stream
      if (!controller.isClosed) {
        controller.close();
      }
    } catch (e, stackTrace) {
      print("SendMessageUseCase Error: $e\n$stackTrace");
      if (!controller.isClosed) {
        controller.addError(e, stackTrace); // Emit error into the stream
        controller.close(); // Close stream after error
      }
    }
  }

  // --- Direct AI Streaming Logic ---
  Future<void> _streamDirectAiResponse({
    required String userMessageText,
    required List<AiContent> historyForApi,
    required AiContent userMessageForHistory,
    required StreamController<SendMessageUpdate> controller,
  }) async {
    final responseStream = _aiRepository.sendMessageStream(
      userMessageText, // Send only the new prompt text
      historyForApi, // Send the history separately
    );

    final fullResponseBuffer = StringBuffer();
    AiContent? finalContent;

    await for (final AiStreamChunk chunk in responseStream) {
      if (controller.isClosed) break; // Stop if listener cancelled
      controller.add(SendMessageChunkUpdate(chunk.textDelta));
      fullResponseBuffer.write(chunk.textDelta);
    }

    // After stream completion (if not closed)
    if (!controller.isClosed && fullResponseBuffer.isNotEmpty) {
      finalContent = AiContent.model(fullResponseBuffer.toString());
      controller.add(SendMessageFinalContentUpdate(finalContent));
    }
    // Stream completion is handled by _executeSendMessage closing the controller
  }

  // --- MCP Orchestration Logic ---
  Future<void> _orchestrateMcpQuery({
    required String userMessageText,
    required List<AiContent> historyForApi,
    required AiContent userMessageForHistory,
    required McpClientState mcpState,
    required StreamController<SendMessageUpdate> controller,
  }) async {
    const int maxIterations = 5;
    final allTools = mcpState.discoveredTools.entries
        .expand((entry) => entry.value.map((tool) => MapEntry(entry.key, tool)))
        .toList();

    // Build AiTool definition from discovered MCP tools
    final aiToolDeclarations = allTools.map((entry) {
      final mcpTool = entry.value;
      return AiFunctionDeclaration(
        // Ensure unique function names if needed, though MCP names should be unique per server
        name: mcpTool.name,
        description:
            mcpTool.description ?? "Executes the ${mcpTool.name} tool.",
        parameters: AiSchema.fromSchemaMap(mcpTool.inputSchema),
      );
    }).toList();

    AiTool? agentAiTool = aiToolDeclarations.isNotEmpty
        ? AiTool(functionDeclarations: aiToolDeclarations)
        : null;

    // If no tools, just do a direct generation call
    if (agentAiTool == null) {
      print(
          "SendMessageUseCase: MCP path selected but no tools found/translated. Falling back to direct generation.");
      controller.add(const SendMessageThinkingUpdate(
          "No tools available, answering directly..."));
      final finalResponse = await _aiRepository
          .generateContent([...historyForApi, userMessageForHistory]);
      final finalContent = finalResponse.firstCandidateContent;
      if (finalContent != null && !controller.isClosed) {
        controller.add(SendMessageFinalContentUpdate(finalContent));
        // Stream text chunks from the final content if it's long? Or just send whole.
        // For simplicity, sending whole via FinalContent update.
      }
      return; // Finished orchestration (fallback path)
    }

    List<AiContent> agentConversation = [
      ...historyForApi,
      userMessageForHistory
    ];
    int iterationCount = 0;
    bool agentThinking = true;

    controller.add(const SendMessageThinkingUpdate("Planning approach..."));

    while (agentThinking && iterationCount < maxIterations) {
      if (controller.isClosed) return; // Check before each iteration

      iterationCount++;
      print("SendMessageUseCase: Agent iteration $iterationCount");

      final aiResponse = await _aiRepository.generateContent(
        agentConversation,
        tools: [agentAiTool], // Provide the tools to the AI
      );

      final aiContent = aiResponse.firstCandidateContent;
      if (aiContent == null) {
        throw Exception("Agent received empty response from AI.");
      }
      if (controller.isClosed) return;

      agentConversation = [
        ...agentConversation,
        aiContent
      ]; // Add AI's response/thought

      final functionCalls =
          aiContent.parts.whereType<AiFunctionCallPart>().toList();

      if (functionCalls.isEmpty) {
        // Agent decided to respond directly
        agentThinking = false;
        print(
            "SendMessageUseCase: Agent iteration $iterationCount finished with direct answer.");
        // The final aiContent *is* the answer
        if (!controller.isClosed) {
          controller.add(SendMessageFinalContentUpdate(aiContent));
        }
        continue; // Exit loop
      }

      // --- Process Tool Calls ---
      final List<AiFunctionResponsePart> functionResponses = [];
      for (final functionCall in functionCalls) {
        if (controller.isClosed) return;

        final toolName = functionCall.name;
        final toolArgs = functionCall.args;
        // Find the server and tool definition again (could optimize)
        final toolEntry =
            allTools.firstWhereOrNull((entry) => entry.value.name == toolName);
        final serverId = toolEntry?.key;

        if (serverId == null) {
          print(
              "SendMessageUseCase: Could not find server for tool '$toolName'.");
          functionResponses.add(AiFunctionResponsePart(
              name: toolName,
              response: {'error': "Tool '$toolName' not found."}));
          continue; // Skip this call
        }

        // TODO: Get server name - requires SettingsRepository or passing config through state
        final serverName = mcpState.serverStatuses.keys
                .firstWhereOrNull((id) => id == serverId) ??
            serverId; // Placeholder

        // Emit Tool Call Update
        controller.add(SendMessageToolCallUpdate(
          toolName: toolName,
          toolArgs: toolArgs,
          serverId: serverId,
          serverName: serverName,
        ));

        try {
          // Execute the tool via McpRepository
          final toolResultContent = await _mcpRepository.executeTool(
            serverId: serverId,
            toolName: toolName,
            arguments: functionCall.args,
          );

          if (controller.isClosed) return;

          // Process result (simplify to text for now)
          final resultText = toolResultContent
              .whereType<McpTextContent>()
              .map((t) => t.text)
              .join('\n')
              .trim();

          // Add successful function response
          functionResponses.add(AiFunctionResponsePart(
            name: toolName,
            response: {
              'result': resultText.isEmpty ? "(No text output)" : resultText
            },
          ));

          // Emit Tool Result Update (Optional)
          controller.add(SendMessageToolResultUpdate(
              toolName: toolName,
              resultText: resultText));
        } catch (e) {
          print(
              "SendMessageUseCase: Error executing tool '$toolName' on server '$serverId': $e");
          if (controller.isClosed) return;
          // Add error function response
          functionResponses.add(AiFunctionResponsePart(
            name: toolName,
            response: {'error': "Execution failed: $e"},
          ));
          // Optionally emit an error update specific to the tool?
          // controller.addError(ToolExecutionFailure(message: "Failed tool '$toolName': $e")); // Or handle within stream
        }
      } // End of function call loop

      // Add tool responses back to the conversation history
      if (functionResponses.isNotEmpty) {
        final toolResponseContent =
            AiContent(role: 'tool', parts: functionResponses);
        agentConversation = [...agentConversation, toolResponseContent];
      }

      // Loop continues for next AI thought...
    } // End of while loop

    // --- Final Answer Generation (if needed) ---
    if (agentThinking && !controller.isClosed) {
      // Max iterations reached, force a final answer
      print(
          "SendMessageUseCase: Max iterations ($maxIterations) reached. Forcing final answer.");
      controller
          .add(const SendMessageThinkingUpdate("Summarizing information..."));

      // Add a final prompt asking the AI to conclude
      agentConversation = [
        ...agentConversation,
        AiContent.user(
            "Please provide the final answer based on our conversation.")
      ];

      final finalResponse = await _aiRepository
          .generateContent(agentConversation); // No tools this time
      final finalContent = finalResponse.firstCandidateContent;

      if (finalContent != null && !controller.isClosed) {
        controller.add(SendMessageFinalContentUpdate(finalContent));
      }
    }
    // If agentThinking is false, the final answer was already emitted in the loop.
    // Controller closure handled by the main execution block.
  }
}
