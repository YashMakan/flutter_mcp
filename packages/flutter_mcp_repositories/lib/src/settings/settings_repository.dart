import 'package:dartz/dartz.dart';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';

/// Abstract repository for managing application settings.
abstract class SettingsRepository {
  // API Key
  Future<Either<Failure, String?>> getApiKey();
  Future<Either<Failure, Unit>> saveApiKey(String apiKey);
  Future<Either<Failure, Unit>> clearApiKey();

  // MCP Server List
  Future<Either<Failure, List<McpServerConfig>>> getMcpServerList();
  Future<Either<Failure, Unit>> saveMcpServerList(List<McpServerConfig> servers);
}
