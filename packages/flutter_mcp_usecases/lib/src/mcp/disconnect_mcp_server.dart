import 'package:dartz/dartz.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

class DisconnectMcpServerUseCase implements UseCase<Unit, String> {
  final McpRepository repository;

  DisconnectMcpServerUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String serverId) async {
    try {
      await repository.disconnectServer(serverId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure("Failed to disconnect server $serverId: $e"));
    }
  }
}
