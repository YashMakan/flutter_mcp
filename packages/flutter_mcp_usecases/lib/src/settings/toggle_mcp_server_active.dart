import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

class ToggleMcpServerActiveParams extends Equatable {
  final String serverId;
  final bool isActive;

  const ToggleMcpServerActiveParams({
    required this.serverId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [serverId, isActive];
}

class ToggleMcpServerActiveUseCase
    implements UseCase<Unit, ToggleMcpServerActiveParams> {
  final SettingsRepository repository;

  ToggleMcpServerActiveUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ToggleMcpServerActiveParams params) async {
    final getListResult = await repository.getMcpServerList();

    return getListResult.fold(
      (failure) => left(failure),
      (currentList) async {
        final index = currentList.indexWhere((s) => s.id == params.serverId);

        if (index == -1) {
          return left(LogicFailure(
              "Server with ID ${params.serverId} not found for toggle."));
        }

        final newList = List<McpServerConfig>.from(currentList);
        newList[index] = newList[index].copyWith(isActive: params.isActive);

        return await repository.saveMcpServerList(newList);
      },
    );
  }
}
