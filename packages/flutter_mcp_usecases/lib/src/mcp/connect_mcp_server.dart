import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

// --- Parameters ---
class ConnectMcpServerParams extends Equatable {
  final String serverId;
  final String command;
  final String args;
  final Map<String, String> environment;

  const ConnectMcpServerParams({
    required this.serverId,
    required this.command,
    required this.args,
    required this.environment,
  });

  @override
  List<Object?> get props => [serverId, command, args, environment];
}

class ConnectMcpServerUseCase implements UseCase<Unit, ConnectMcpServerParams> {
  final McpRepository repository;

  ConnectMcpServerUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ConnectMcpServerParams params) async {
    try {
      await repository.connectServer(
        serverId: params.serverId,
        command: params.command,
        args: params.args,
        environment: params.environment,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ConnectionFailure("Failed to initiate connection for ${params.serverId}: $e"));
    }
  }
}