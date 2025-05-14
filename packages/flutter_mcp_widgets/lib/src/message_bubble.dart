import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final List<McpServerConfig> serverConfigs;

  const MessageBubble({
    super.key,
    required this.message,
    required this.serverConfigs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    Widget messageContent;
    List<Widget> children = [];

    if (isUser) {
      messageContent = Container(
        padding: EdgeInsets.symmetric(
            vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: Color(0xFF141414),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              radius: 14,
              child: Center(child: Text('YM', style: TextStyle(fontSize: 12),)),
            ),
            SizedBox(width: 6),
            SelectableText(
              message.text,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    } else {
      try {
        messageContent = MarkdownBody(
          data: message.text,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
              listBullet:
                  TextStyle(color: Colors.white, fontFamily: 'Copernicus'),
              p: TextStyle(color: Colors.white, fontFamily: 'Copernicus')),
        );
      } catch (e) {
        debugPrint("Markdown rendering error: $e");
        messageContent = SelectableText(
          "Error rendering message content.\n\n${message.text}",
        );
      }
    }

    children.add(messageContent);
    children.add(SizedBox(height: isUser?16:36));

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
