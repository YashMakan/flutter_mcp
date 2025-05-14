import 'package:dartz/dartz.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

class ClearApiKeyUseCase implements UseCaseWithoutParams<Unit> {
  final SettingsRepository repository;

  ClearApiKeyUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call() async {
    return await repository.clearApiKey();
  }
}