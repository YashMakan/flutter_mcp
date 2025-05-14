import 'package:dartz/dartz.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';
import 'package:flutter_mcp_datasources/flutter_mcp_datasources.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, String?>> getApiKey() async {
    try {
      return right(await localDataSource.getApiKey());
    } catch (e) {
      return left(LogicFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveApiKey(String apiKey) async {
    try {
      await localDataSource.saveApiKey(apiKey);
      return right(unit);
    } catch (e) {
      return left(const LogicFailure("Repository: Failed to save API Key"));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearApiKey() async {
    try {
      await localDataSource.clearApiKey();
      return right(unit);
    } catch (e) {
      return left(const LogicFailure("Repository: Failed to clear API Key"));
    }
  }

  @override
  Future<Either<Failure, List<McpServerConfig>>> getMcpServerList() async {
    try {
      final servers = await localDataSource.getMcpServerList();
      return right(servers);
    } catch (e) {
      return left(LogicFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveMcpServerList(
      List<McpServerConfig> servers) async {
    try {
      await localDataSource.saveMcpServerList(servers);
      return right(unit);
    } catch (e) {
      return left(const LogicFailure("Repository: Failed to save MCP list"));
    }
  }
}
