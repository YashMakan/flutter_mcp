import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_state/src/mcp/mcp_cubit.dart';
import 'package:flutter_mcp_state/src/settings/settings_cubit.dart';
import 'package:flutter_mcp_usecases/flutter_mcp_usecases.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final GetApiKeyUseCase _getApiKeyUseCase;
  final SettingsCubit _settingsCubit;
  final McpCubit _mcpCubit;

  StreamSubscription? _settingsSubscription;
  StreamSubscription? _mcpSubscription;
  StreamSubscription<SendMessageUpdate>?
      _messageStreamSubscription; // Listen to use case stream

  ChatCubit({
    required SendMessageUseCase sendMessageUseCase,
    required GetApiKeyUseCase getApiKeyUseCase,
    required SettingsCubit settingsCubit,
    required McpCubit mcpCubit,
  })  : _sendMessageUseCase = sendMessageUseCase,
        _getApiKeyUseCase = getApiKeyUseCase,
        _settingsCubit = settingsCubit,
        _mcpCubit = mcpCubit,
        super(const ChatState()) {
    _listenToDependencies();
  }

  void _listenToDependencies() {
    _settingsSubscription = _settingsCubit.stream.listen((settingsState) {
      if (!isClosed && state.isApiKeySet != (settingsState.apiKey != null)) {
        emit(state.copyWith(isApiKeySet: settingsState.apiKey != null));
      }
    });

    _mcpSubscription = _mcpCubit.stream.listen((mcpState) {
      if (!isClosed) {
        final mcpDomainState = mcpState.mcpClientState;
        // Consider MCP available if connected AND has discoverable tools
        final bool available = mcpDomainState.hasActiveConnections &&
            mcpDomainState.discoveredTools.values
                .any((list) => list.isNotEmpty);
        if (state.isMcpAvailable != available) {
          emit(state.copyWith(isMcpAvailable: available));
        }
      }
    });
  }

  /// Call this after creation to set initial dependent state values.
  Future<void> initialize() async {
    print("ChatCubit initializing...");
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final apiKeyUseCase = await _getApiKeyUseCase.call();
      apiKeyUseCase.fold((l) => null, (r) {
        final initialMcpState = _mcpCubit.state.mcpClientState;
        final bool mcpAvailable = initialMcpState.hasActiveConnections &&
            initialMcpState.discoveredTools.values
                .any((list) => list.isNotEmpty);

        emit(state.copyWith(
          status: ChatStatus.loaded,
          isApiKeySet: r != null && r.isNotEmpty,
          isMcpAvailable: mcpAvailable,
        ));
        print(
            "ChatCubit initialized: API Key Set = ${state.isApiKeySet}, MCP Available = ${state.isMcpAvailable}");
      });
    } catch (e) {
      print("ChatCubit initialization error: $e");
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: "Failed to initialize chat: ${e.toString()}",
        isApiKeySet: false, // Assume false on error
        isMcpAvailable: false,
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (state.status == ChatStatus.loadingMessage ||
        state.status == ChatStatus.messageStreaming) {
      print("ChatCubit: Message sending blocked, already processing.");
      return;
    }
    if (!state.isApiKeySet) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: "Cannot send message: API Key is not set.",
      ));
      return;
    }

    await _messageStreamSubscription?.cancel(); // Cancel previous stream if any

    final userMessageText = text.trim();
    final userMessageDisplay = ChatMessage(text: userMessageText, isUser: true);
    final userMessageHistory = AiContent.user(userMessageText);

    // Add user message and placeholder for AI response
    final currentMessages = List<ChatMessage>.from(state.displayMessages);
    currentMessages.add(userMessageDisplay);
    currentMessages
        .add(const ChatMessage(text: "", isUser: false)); // Placeholder

    emit(state.copyWith(
      status: ChatStatus.loadingMessage,
      displayMessages: currentMessages,
      clearErrorMessage: true,
    ));

    final historyForApi = List<AiContent>.from(state.chatHistory);
    final params = SendMessageParams(
      prompt: userMessageText,
      history: historyForApi,
      // The use case should internally decide whether to use MCP based on McpRepository state
    );

    final streamUseCase = await _sendMessageUseCase.call(params);
    streamUseCase.fold((l) => null, (stream) {
      final StringBuffer responseBuffer = StringBuffer();
      ChatMessage lastAiMessage = currentMessages.last;
      AiContent?
          finalAiResponseContent; // To store the final AI content for history

      _messageStreamSubscription = stream.listen(
        (update) {
          if (isClosed) return;

          final currentMessages = List<ChatMessage>.from(state.displayMessages);
          if (currentMessages.isEmpty || currentMessages.last.isUser) {
            print(
                "ChatCubit: Stream update received, but displayMessages state is inconsistent.");
            _messageStreamSubscription?.cancel();
            if (state.status != ChatStatus.error) {
              // Avoid overwriting existing error
              emit(state.copyWith(
                  status: ChatStatus.error,
                  errorMessage: "Internal chat state error."));
            }
            return;
          }

          // Process the update from the use case
          update.when(
            chunk: (delta) {
              responseBuffer.write(delta);
              lastAiMessage =
                  lastAiMessage.copyWith(text: responseBuffer.toString());
              currentMessages[currentMessages.length - 1] = lastAiMessage;
              emit(state.copyWith(
                  status: ChatStatus.messageStreaming,
                  displayMessages: currentMessages));
            },
            toolCall: (toolName, toolArgs, serverId, serverName) {
              responseBuffer
                  .clear(); // Clear buffer when tool call starts? Or keep thinking message?
              lastAiMessage = lastAiMessage.copyWith(
                text: "🤔 Thinking... (using $toolName)",
                toolName: toolName,
                toolArgs: jsonEncode(toolArgs),
                sourceServerId: serverId,
                sourceServerName: serverName,
              );
              currentMessages[currentMessages.length - 1] = lastAiMessage;
              emit(state.copyWith(
                  status: ChatStatus.loadingMessage,
                  displayMessages:
                      currentMessages)); // Back to loading for tool
            },
            toolResult: (toolName, resultText) {
              // Maybe display result briefly? Or just wait for final AI summary
              lastAiMessage = lastAiMessage.copyWith(
                toolResult: resultText,
                text: "Got result from \"$toolName\". Preparing final answer...",
              );
              currentMessages[currentMessages.length - 1] = lastAiMessage;
              emit(state.copyWith(
                  status: ChatStatus.loadingMessage,
                  displayMessages: currentMessages));
            },
            finalContent: (content) {
              final finalText =
                  content.text; // Assuming AiContent has a text getter
              responseBuffer.clear();
              responseBuffer.write(finalText);
              lastAiMessage =
                  lastAiMessage.copyWith(text: finalText);
              currentMessages[currentMessages.length - 1] = lastAiMessage;
              finalAiResponseContent = content; // Store for history
              // Don't emit final 'loaded' state here, wait for onDone
              emit(state.copyWith(
                  displayMessages: currentMessages)); // Update display
            },
            thinking: (String message) {},
          );
        },
        onError: (error) {
          if (isClosed) return;
          print("ChatCubit: Error in message stream: $error");
          final errorText = "Error: ${error.toString()}";
          final currentMessages = List<ChatMessage>.from(state.displayMessages);
          if (currentMessages.isNotEmpty && !currentMessages.last.isUser) {
            currentMessages[currentMessages.length - 1] =
                currentMessages.last.copyWith(text: errorText);
          } else {
            currentMessages.add(ChatMessage(text: errorText, isUser: false));
          }

          emit(state.copyWith(
            status: ChatStatus.error,
            errorMessage: error.toString(),
            displayMessages: currentMessages,
          ));
          _messageStreamSubscription = null;
        },
        onDone: () {
          if (isClosed) return;
          print("ChatCubit: Message stream finished.");
          _messageStreamSubscription = null;

          if (state.status != ChatStatus.error) {
            // Update history only if successful and final content received
            List<AiContent> updatedHistory = List.from(historyForApi);
            updatedHistory.add(userMessageHistory);
            if (finalAiResponseContent != null) {
              updatedHistory.add(finalAiResponseContent!);
            } else if (responseBuffer.isNotEmpty) {
              // Fallback if finalContent wasn't emitted but we got chunks
              updatedHistory.add(AiContent.model(responseBuffer.toString()));
            }

            emit(state.copyWith(
              status: ChatStatus.loaded,
              chatHistory: updatedHistory, // Commit history
            ));
          } else {
            // Ensure status is error if stream completed after an error occurred
            if (state.status != ChatStatus.error) {
              emit(state.copyWith(
                  status: ChatStatus.error,
                  errorMessage: "Failed to get complete response."));
            }
          }
        },
        cancelOnError: true,
      );
    });
  }

  void clearChat() {
    print("ChatCubit: Clearing chat.");
    _messageStreamSubscription?.cancel();
    _messageStreamSubscription = null;
    emit(state.copyWith(
      status: ChatStatus.loaded,
      displayMessages: [],
      chatHistory: [],
      clearErrorMessage: true,
    ));
    print("CUBIT_POST_EMIT: New state hashCode: ${state.hashCode}, messages: ${state.displayMessages.length}");
  }

  @override
  Future<void> close() {
    print("ChatCubit: Closing.");
    _settingsSubscription?.cancel();
    _mcpSubscription?.cancel();
    _messageStreamSubscription?.cancel();
    return super.close();
  }
}
