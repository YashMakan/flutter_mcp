part of 'package:flutter_mcp_entities/src/ai/ai_part.dart';

/// Represents a function call requested by the model.
class AiFunctionCallPart extends AiPart {
  final String name;
  final Map<String, dynamic> args;

  const AiFunctionCallPart({required this.name, required this.args});

  @override
  Part toGoogleGenAi() => FunctionCall(name, args);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiFunctionCallPart &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          const MapEquality().equals(args, other.args);

  @override
  int get hashCode => name.hashCode ^ const MapEquality().hash(args);
}
