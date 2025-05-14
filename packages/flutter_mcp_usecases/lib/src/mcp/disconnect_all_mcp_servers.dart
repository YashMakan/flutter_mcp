import 'package:dartz/dartz.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

class DisconnectAllMcpServersUseCase implements UseCaseWithoutParams<Unit> {
  final McpRepository repository;

  DisconnectAllMcpServersUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call() async {
    try {
      await repository.disconnectAllServers();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure("Failed to disconnect all servers: $e"));
    }
  }
}
