import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_state/flutter_mcp_state.dart';
import 'package:flutter_mcp_widgets/flutter_mcp_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(
      text: context.read<SettingsCubit>().state.apiKey ?? '',
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _showSnackbar(BuildContext ctx, String message) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).removeCurrentSnackBar();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _saveApiKey(BuildContext ctx) {
    final newApiKey = _apiKeyController.text.trim();
    ctx.read<SettingsCubit>().saveApiKey(newApiKey);
    FocusScope.of(ctx).unfocus();
  }

  void _clearApiKey(BuildContext ctx) {
    ctx.read<SettingsCubit>().clearApiKey();
    _apiKeyController.clear();
    FocusScope.of(ctx).unfocus();
  }

  void _toggleServerActive(BuildContext ctx, String serverId, bool isActive) {
    ctx.read<SettingsCubit>().toggleMcpServerActive(serverId, isActive);
  }

  void _openServerDialog(BuildContext ctx, {McpServerConfig? serverToEdit}) {
    showServerDialog(
      context: ctx,
      serverToEdit: serverToEdit,
      onAddServer: (name, command, args, envVars, isActive) {
        ctx.read<SettingsCubit>().addMcpServer(name, command, args, envVars);
      },
      onUpdateServer: (updatedServer) {
        ctx.read<SettingsCubit>().updateMcpServer(updatedServer);
      },
      onError: (message) => _showSnackbar(ctx, message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (_apiKeyController.text != (state.apiKey ?? '')) {
              _apiKeyController.text = state.apiKey ?? '';
            }
            if (state.status == SettingsStatus.error &&
                state.errorMessage != null) {
              _showSnackbar(context, state.errorMessage!);
            }
          },
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final currentApiKey = settingsState.apiKey;
          final serverList = settingsState.serverList;
          final isLoading = settingsState.status == SettingsStatus.loading;

          return BlocBuilder<McpCubit, McpState>(
            builder: (context, mcpState) {
              final mcpDomainState = mcpState.mcpClientState;
              final serverStatuses = mcpDomainState.serverStatuses;
              final serverErrors = mcpDomainState.serverErrorMessages;
              final connectedCount = mcpDomainState.connectedServerCount;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ApiKeyTextField(
                          controller: _apiKeyController,
                          currentApiKey: currentApiKey,
                          onSave: () => _saveApiKey(context),
                          onClear: () => _clearApiKey(context),
                        ),
                        const SizedBox(height: 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MCP Servers',
                                  style: TextStyle(
                                      fontFamily: 'Copernicus',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  '$connectedCount server(s) connected. Changes are applied automatically.',
                                  style: TextStyle(
                                      fontFamily: 'Copernicus',
                                      fontSize: 12.0,
                                      color: Colors.grey.withOpacity(.4)),
                                ),
                              ],
                            ),
                            CustomIconButton(
                                icon: 'assets/icons/add.svg',
                                color: const Color(0xFFc96442),
                                onTap: () => _openServerDialog(context),
                                showBorder: false),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        serverList.isEmpty
                            ? const SizedBox()
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: serverList.length,
                                itemBuilder: (ctx, index) {
                                  final server = serverList[index];
                                  final status = serverStatuses[server.id] ??
                                      McpConnectionStatus.disconnected;
                                  final error = serverErrors[server.id];

                                  return McpServerListItem(
                                      server: server,
                                      status: status,
                                      errorMessage: error,
                                      onToggleActive: (id, isActive) =>
                                          _toggleServerActive(
                                              context, id, isActive),
                                      onEdit: (srv) => _openServerDialog(
                                          context,
                                          serverToEdit: srv),
                                      onDelete: (srv) => ctx
                                          .read<SettingsCubit>()
                                          .deleteMcpServer(server.id));
                                },
                              ),
                        const SizedBox(height: 12.0),
                      ],
                    ),
                  ),
                  if (isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
