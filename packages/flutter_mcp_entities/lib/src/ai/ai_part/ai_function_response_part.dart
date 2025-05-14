part of 'package:flutter_mcp_entities/src/ai/ai_part.dart';

/// Represents the response from a function call execution.
class AiFunctionResponsePart extends AiPart {
  final String name;
  final Map<String, dynamic> response;
  const AiFunctionResponsePart({required this.name, required this.response});

  @override
  Part toGoogleGenAi() => FunctionResponse(name, response);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AiFunctionResponsePart &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              const MapEquality().equals(response, other.response);

  @override
  int get hashCode => name.hashCode ^ const MapEquality().hash(response);
}