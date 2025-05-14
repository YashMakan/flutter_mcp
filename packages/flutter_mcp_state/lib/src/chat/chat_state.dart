part of 'chat_cubit.dart';

enum ChatStatus {
  initial, // Before anything happens
  loading, // Generic loading (e.g., initial checks)
  loadingMessage, // Waiting for AI/MCP response
  messageStreaming, // Receiving AI response stream deltas
  loaded, // Idle, ready for input or displaying complete response
  error, // An error occurred
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> displayMessages; // Messages shown in the UI
  final List<AiContent> chatHistory; // History for the AI context
  final bool isApiKeySet;
  final bool isMcpAvailable; // True if MCP connected AND has tools
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.displayMessages = const [],
    this.chatHistory = const [],
    this.isApiKeySet = false,
    this.isMcpAvailable = false,
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? displayMessages,
    List<AiContent>? chatHistory,
    bool? isApiKeySet,
    bool? isMcpAvailable,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      displayMessages: displayMessages ?? this.displayMessages,
      chatHistory: chatHistory ?? this.chatHistory,
      isApiKeySet: isApiKeySet ?? this.isApiKeySet,
      isMcpAvailable: isMcpAvailable ?? this.isMcpAvailable,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    displayMessages,
    chatHistory,
    isApiKeySet,
    isMcpAvailable,
    errorMessage,
  ];
}