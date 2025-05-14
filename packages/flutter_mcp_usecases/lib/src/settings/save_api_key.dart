import 'package:dartz/dartz.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

class SaveApiKeyUseCase implements UseCase<void, String> {
  final SettingsRepository repository;

  SaveApiKeyUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String apiKey) async {
    return await repository.saveApiKey(apiKey);
  }
}