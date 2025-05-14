import 'package:dartz/dartz.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

class UpdateMcpServerUseCase implements UseCase<Unit, McpServerConfig> {
  final SettingsRepository repository;

  UpdateMcpServerUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(McpServerConfig serverToUpdate) async {
    final getListResult = await repository.getMcpServerList();

    return getListResult.fold(
          (failure) => left(failure),
          (currentList) async {
        final index = currentList.indexWhere((s) => s.id == serverToUpdate.id);

        if (index == -1) {
          return left(LogicFailure(
              "Server with ID ${serverToUpdate.id} not found for update."));
        }

        final newList = List<McpServerConfig>.from(currentList);
        newList[index] = serverToUpdate;
        
        return await repository.saveMcpServerList(newList);
      },
    );
  }
}