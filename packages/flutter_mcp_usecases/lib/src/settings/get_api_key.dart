import 'package:dartz/dartz.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

class GetApiKeyUseCase implements UseCaseWithoutParams<String?> {
  final SettingsRepository repository;

  GetApiKeyUseCase(this.repository);

  @override
  Future<Either<Failure, String?>> call() async {
    return await repository.getApiKey();
  }
}