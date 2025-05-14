import 'package:dartz/dartz.dart';
import 'dart:async';
import 'package:flutter_mcp_core/flutter_mcp_core.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_repositories/flutter_mcp_repositories.dart';

class GetMcpStateStreamUseCase implements UseCaseWithoutParams<Stream<McpClientState>> {
  final McpRepository repository;

  GetMcpStateStreamUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<McpClientState>>> call() async {
    try {
      final stream = repository.mcpStateStream;
      return Right(stream);
    } catch (e) {
      return Left(ServerFailure("Failed to access MCP state stream: $e"));
    }
  }
}