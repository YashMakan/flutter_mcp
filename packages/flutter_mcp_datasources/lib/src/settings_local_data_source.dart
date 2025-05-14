import 'dart:convert';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String apiKeyStorageKey = 'geminiApiKey';
const String mcpServerListKey = 'mcpServerList';

abstract class SettingsLocalDataSource {
  Future<String?> getApiKey();
  Future<void> saveApiKey(String apiKey);
  Future<void> clearApiKey();
  Future<List<McpServerConfig>> getMcpServerList();
  Future<void> saveMcpServerList(List<McpServerConfig> servers);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String?> getApiKey() async {
    return sharedPreferences.getString(apiKeyStorageKey);
  }

  @override
  Future<void> saveApiKey(String apiKey) async {
    try {
      await sharedPreferences.setString(apiKeyStorageKey, apiKey);
    } catch (e) {
      print("Error saving API key in data source: $e");
      throw Exception("Failed to save API key"); // Or a custom CacheException
    }
  }

  @override
  Future<void> clearApiKey() async {
    try {
      await sharedPreferences.remove(apiKeyStorageKey);
    } catch (e) {
      print("Error clearing API key in data source: $e");
      throw Exception("Failed to clear API key");
    }
  }

  @override
  Future<List<McpServerConfig>> getMcpServerList() async {
    try {
      final serverListJson = sharedPreferences.getString(mcpServerListKey);
      if (serverListJson != null && serverListJson.isNotEmpty) {
        final decodedList = jsonDecode(serverListJson) as List;
        final configList =
        decodedList
            .map(
              (item) =>
              McpServerConfig.fromJson(item as Map<String, dynamic>),
        )
            .toList();
        return configList;
      }
      return [];
    } catch (e) {
      print("Error loading/parsing server list in data source: $e");
      throw Exception("Failed to load server list");
    }
  }

  @override
  Future<void> saveMcpServerList(List<McpServerConfig> servers) async {
    try {
      final serverListJson = jsonEncode(
        servers.map((s) => s.toJson()).toList(),
      );
      await sharedPreferences.setString(mcpServerListKey, serverListJson);
    } catch (e) {
      print("Error saving MCP server list in data source: $e");
      throw Exception("Failed to save server list");
    }
  }
}