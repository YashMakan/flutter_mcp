part of 'mcp_cubit.dart';

class McpState extends Equatable {
  final McpClientState mcpClientState;

  const McpState({
    this.mcpClientState = const McpClientState(), // Default empty state
  });

  McpState copyWith({McpClientState? mcpClientState}) {
    return McpState(
      mcpClientState: mcpClientState ?? this.mcpClientState,
    );
  }

  @override
  List<Object> get props => [mcpClientState];
}
