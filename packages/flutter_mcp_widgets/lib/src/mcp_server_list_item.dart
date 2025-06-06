import 'package:flutter/material.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'mcp_connection_status_indicator.dart';

class McpServerListItem extends StatelessWidget {
  final McpServerConfig server;
  final McpConnectionStatus status;
  final String? errorMessage;
  final Function(String, bool) onToggleActive;
  final Function(McpServerConfig) onEdit;
  final Function(McpServerConfig) onDelete;

  const McpServerListItem({
    super.key,
    required this.server,
    required this.status,
    this.errorMessage,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool userWantsActive = server.isActive;
    final int customEnvCount = server.customEnvironment.length;
    Color containerBgColor = Color(0xFF30302d);

    return Card(
      elevation: 0,
      color: containerBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Tooltip(
              message: status.name,
              child: McpConnectionStatusIndicator(status: status),
            ),
            trailing: SizedBox(
              width: 36,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Switch(
                  value: userWantsActive,
                  onChanged: (bool value) => onToggleActive(server.id, value),
                  activeColor: Colors.green,
                ),
              ),
            ),
            title: Text(
              server.name,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${server.command} ${server.args}'.trim(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (customEnvCount > 0)
                  Text(
                    '$customEnvCount custom env var(s)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blueGrey,
                    ),
                  ),
              ],
            ),
            onLongPress: () => onEdit(server),
          ),
          // Error and Action Row
          Padding(
            padding: const EdgeInsets.only(left: 52.0, right: 8.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child:
                      errorMessage != null
                          ? Tooltip(
                            message: errorMessage!,
                            child: Text(
                              'Error: $errorMessage',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          )
                          : const SizedBox(height: 14),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, size: 20, color: Colors.white30,),
                      tooltip: 'Edit Server',
                      onPressed: () => onEdit(server),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: 'Delete Server',
                      onPressed: () => onDelete(server),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
