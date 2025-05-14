import 'package:dartz/dartz.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

class AddMcpServerUseCase implements UseCase<Unit, McpServerConfig> {
  final SettingsRepository repository;

  AddMcpServerUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(McpServerConfig serverToAdd) async {
    final getListResult = await repository.getMcpServerList();

    return getListResult.fold(
          (failure) => left(failure),
          (currentList) async {
        final newList = [...currentList, serverToAdd];
        return await repository.saveMcpServerList(newList);
      },
    );
  }
}