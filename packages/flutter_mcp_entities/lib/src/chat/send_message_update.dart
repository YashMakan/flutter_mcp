import 'package:equatable/equatable.dart';
import 'package:flutter_mcp_entities/src/ai/ai_content.dart';

// Base class for updates streamed by SendMessageUseCase
abstract class SendMessageUpdate extends Equatable {
  const SendMessageUpdate();
}

/// Represents a text chunk received during streaming (direct AI or final answer).
class SendMessageChunkUpdate extends SendMessageUpdate {
  final String textDelta;

  const SendMessageChunkUpdate(this.textDelta);

  @override
  List<Object?> get props => [textDelta];
}

/// Indicates that an MCP tool call is being initiated.
class SendMessageToolCallUpdate extends SendMessageUpdate {
  final String toolName;
  final String serverId;
  final Map<String, dynamic> toolArgs;
  final String serverName; // Helpful for display

  const SendMessageToolCallUpdate({
    required this.toolName,
    required this.toolArgs,
    required this.serverId,
    required this.serverName,
  });

  @override
  List<Object?> get props => [toolName, toolArgs, serverId, serverName];
}

/// Indicates the result received from an MCP tool call.
/// (Could be simplified if only the final AI summary is needed)
class SendMessageToolResultUpdate extends SendMessageUpdate {
  final String toolName;
  final String resultText; // Simplified result for display

  const SendMessageToolResultUpdate({
    required this.toolName,
    required this.resultText,
  });

  @override
  List<Object?> get props => [toolName, resultText];
}

/// Represents the final, complete AI content after all processing.
class SendMessageFinalContentUpdate extends SendMessageUpdate {
  final AiContent content; // The complete structured content

  const SendMessageFinalContentUpdate(this.content);

  @override
  List<Object?> get props => [content];
}

/// Represents an intermediate thinking/planning step message.
class SendMessageThinkingUpdate extends SendMessageUpdate {
  final String message;

  const SendMessageThinkingUpdate(this.message);

  @override
  List<Object?> get props => [message];
}


// Extension to mimic 'when' for easier handling in Cubit/Bloc if not using sealed classes/freezed
// Optional, but useful based on your Cubit example.
extension SendMessageUpdateMatcher on SendMessageUpdate {
  T when<T>({
    required T Function(String delta) chunk,
    required T Function(String toolName,Map<String, dynamic> toolArgs, String serverId, String serverName) toolCall,
    required T Function(String toolName, String resultText) toolResult,
    required T Function(AiContent content) finalContent,
    required T Function(String message) thinking,
    // Add an 'orElse' if needed for exhaustive checks without errors
    // T Function()? orElse,
  }) {
    if (this is SendMessageChunkUpdate) {
      return chunk((this as SendMessageChunkUpdate).textDelta);
    } else if (this is SendMessageToolCallUpdate) {
      final update = this as SendMessageToolCallUpdate;
      return toolCall(update.toolName, update.toolArgs, update.serverId, update.serverName);
    } else if (this is SendMessageToolResultUpdate) {
      final update = this as SendMessageToolResultUpdate;
      return toolResult(update.toolName, update.resultText);
    } else if (this is SendMessageFinalContentUpdate) {
      return finalContent((this as SendMessageFinalContentUpdate).content);
    } else if (this is SendMessageThinkingUpdate) {
      return thinking((this as SendMessageThinkingUpdate).message);
    }
    // else if (orElse != null) {
    //   return orElse();
    // }
    else {
      throw Exception('Unhandled SendMessageUpdate type: $runtimeType');
    }
  }
}