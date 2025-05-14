import 'package:dartz/dartz.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

class DeleteMcpServerUseCase implements UseCase<Unit, String> {
  final SettingsRepository repository;

  DeleteMcpServerUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String serverIdToDelete) async {
    final getListResult = await repository.getMcpServerList();

    return getListResult.fold(
      (failure) => left(failure),
      (currentList) async {
        final newList =
            currentList.where((s) => s.id != serverIdToDelete).toList();
        return await repository.saveMcpServerList(newList);
      },
    );
  }
}
