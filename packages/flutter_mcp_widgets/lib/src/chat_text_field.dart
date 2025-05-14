import 'package:flutter/material.dart';
import 'package:flutter_mcp_widgets/src/common/gradient_border.dart';
import 'package:flutter_mcp_widgets/src/common/icon_button.dart';
import 'package:flutter_mcp_widgets/src/mcp_connection_status_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatTextField extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final bool isApiKeySet;
  final bool isReplying;
  final int? serversCount;
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAdd;
  final VoidCallback onModify;

  const ChatTextField(
      {super.key,
      required this.enabled,
      required this.isLoading,
      required this.isReplying,
      required this.isApiKeySet,
      required this.onSend,
      required this.onAdd,
      required this.onModify,
      required this.controller,
      this.serversCount});

  @override
  Widget build(BuildContext context) {
    Color primaryTextColor = Colors.white.withOpacity(0.85);
    Color secondaryTextColor = Colors.white.withOpacity(0.6);
    Color containerBgColor = Color(0xFF30302d);

    Color sendButtonColor = Color(0xFF844c38);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 680),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12),
        decoration: BoxDecoration(
          color: containerBgColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              cursorColor: Colors.white,
              cursorWidth: .8,
              cursorHeight: 16,
              onSubmitted: (_) => onSend(),
              style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w200),
              decoration: InputDecoration(
                hintText: isReplying
                    ? "Reply to claude..."
                    : "How can I help you today?",
                hintStyle: TextStyle(color: secondaryTextColor),
                border: InputBorder.none, // Remove default underline
              ),
            ),
            SizedBox(height: isReplying ? 0 : 32),
            Row(
              children: [
                CustomIconButton(icon: 'assets/icons/add.svg', onTap: onAdd),
                SizedBox(width: 8),
                Tooltip(
                  message:
                  (serversCount??0) > 0
                      ? '$serversCount MCP Server(s) Connected'
                      : 'No MCP Servers Connected',
                  decoration: BoxDecoration(
                    color: Color(0xFF080806),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: SizedBox(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CustomIconButton(
                            icon: 'assets/icons/modify.svg', onTap: onModify),
                        if(serversCount != null)
                          McpConnectionCounter(connectedCount: serversCount!)
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Claude 3.7 Sonnet",
                      style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 13,
                          letterSpacing: -.5,
                          fontFamily: 'Copernicus'),
                    ),
                    SizedBox(width: 4),
                    SvgPicture.asset(
                      'assets/icons/down-arrow.svg',
                      width: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(width: 16),
                CustomIconButton(
                    icon: 'assets/icons/send.svg',
                    color: sendButtonColor,
                    onTap: onSend,
                    showBorder: false),
              ],
            ),
          ],
        ),
      ).gradientBorder(),
    );
  }
}
