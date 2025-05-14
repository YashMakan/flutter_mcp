import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

class ExecuteMcpToolParams extends Equatable {
  final String serverId;
  final String toolName;
  final Map<String, dynamic> arguments;

  const ExecuteMcpToolParams({
    required this.serverId,
    required this.toolName,
    required this.arguments,
  });

  @override
  List<Object?> get props => [serverId, toolName, arguments];
}

class ExecuteMcpToolUseCase
    implements UseCase<List<McpContent>, ExecuteMcpToolParams> {
  final McpRepository repository;

  ExecuteMcpToolUseCase(this.repository);

  @override
  Future<Either<Failure, List<McpContent>>> call(
      ExecuteMcpToolParams params) async {
    try {
      final List<McpContent> result = await repository.executeTool(
        serverId: params.serverId,
        toolName: params.toolName,
        arguments: params.arguments,
      );
      return Right(result);
    } catch (e) {
      if (e is StateError) {
        return Left(ConnectionFailure(
            "Cannot execute tool '${params.toolName}' on ${params.serverId}: ${e.message}"));
      }
      return Left(LogicFailure(

              "Failed to execute tool '${params.toolName}' on ${params.serverId}: $e"));
    }
  }
}
