import 'package:dartz/dartz.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

class GetMcpServerListUseCase
    implements UseCaseWithoutParams<List<McpServerConfig>> {
  final SettingsRepository repository;

  GetMcpServerListUseCase(this.repository);

  @override
  Future<Either<Failure, List<McpServerConfig>>> call() async {
    return await repository.getMcpServerList();
  }
}