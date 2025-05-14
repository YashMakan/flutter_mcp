import 'package:flutter/material.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';

class McpConnectionStatusIndicator extends StatelessWidget {
  final McpConnectionStatus status;

  const McpConnectionStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (status) {
      case McpConnectionStatus.connected:
        return Icon(Icons.check_circle, color: Colors.green[700], size: 20);
      case McpConnectionStatus.connecting:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case McpConnectionStatus.error:
        return Icon(Icons.error, color: theme.colorScheme.error, size: 20);
      case McpConnectionStatus.disconnected:
        return Icon(
          Icons.circle_outlined,
          color: theme.disabledColor,
          size: 20,
        );
    }
  }
}

class McpConnectionCounter extends StatelessWidget {
  final int connectedCount;

  const McpConnectionCounter({super.key, required this.connectedCount});

  @override
  Widget build(BuildContext context) {
    if (connectedCount > 0) {
      return Positioned(
        bottom: -2,
        right: -2,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 7,
          child: Text(
            '$connectedCount',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
