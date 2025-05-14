import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mcp/pages/settings_screen.dart';
import 'package:flutter_mcp_state/flutter_mcp_state.dart';
import 'package:flutter_mcp_widgets/flutter_mcp_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:window_manager/window_manager.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _onModify(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12)
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: const SettingsPage(),
          ),
        );
      },
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _textController.text;
    if (text.trim().isNotEmpty) {
      final messageToSend = text.trim();
      _textController.clear();
      context.read<ChatCubit>().sendMessage(messageToSend);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.hasContentDimensions) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackbar(BuildContext ctx, String message) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).removeCurrentSnackBar();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<ChatCubit, ChatState>(
            listenWhen: (previous, current) =>
                previous.displayMessages.length !=
                    current.displayMessages.length ||
                previous.displayMessages.lastOrNull !=
                    current.displayMessages.lastOrNull,
            listener: (context, state) {
              if (state.status != ChatStatus.error ||
                  state.errorMessage == null) {
                _scrollToBottom();
              }
            },
          ),
          BlocListener<ChatCubit, ChatState>(
            listenWhen: (previous, current) {
              final wasLoading = previous.status == ChatStatus.loadingMessage ||
                  previous.status == ChatStatus.messageStreaming;
              final isNotLoading =
                  current.status != ChatStatus.loadingMessage &&
                      current.status != ChatStatus.messageStreaming;

              if (wasLoading && isNotLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _inputFocusNode.context != null) {
                    _inputFocusNode.requestFocus();
                  }
                });
              }
              return previous.status != current.status;
            },
            listener: (context, state) {},
          ),
          BlocListener<ChatCubit, ChatState>(
            listenWhen: (previous, current) =>
                previous.status != ChatStatus.error &&
                current.status == ChatStatus.error &&
                current.errorMessage != null,
            listener: (context, state) {
              if (state.errorMessage != null) {
                _showSnackbar(context, state.errorMessage!);
              }
            },
          ),
        ],
        child: Column(
          children: [
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, chatState) {
                final messages = chatState.displayMessages;
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 30,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 80),
                          SvgPicture.asset(
                            'assets/icons/sidebar.svg',
                            width: 18,
                          ),
                          if(messages.isNotEmpty) ...[
                            const SizedBox(width: 24),
                            const Text(
                              'Untitled',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            SvgPicture.asset(
                              'assets/icons/down-arrow.svg',
                              width: 12,
                              color: Colors.white,
                            )
                          ],
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanStart: (details) {
                                windowManager.startDragging();
                              },
                              child: const SizedBox(),
                            ),
                          ),
                          if(messages.isNotEmpty)
                          CustomIconButton(
                              icon: 'assets/icons/add.svg',
                              color: const Color(0xFFc96442),
                              onTap: () {
                                context.read<ChatCubit>().clearChat();
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted &&
                                      _inputFocusNode.context != null) {
                                    _inputFocusNode.requestFocus();
                                  }
                                });
                              },
                              showBorder: false),
                          const SizedBox(width: 8)
                        ],
                      ),
                    ),
                if(messages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(
                    color: Color(0xFF494945),
                    height: 0,
                  ),
                  const SizedBox(height: 8),
                ]
                  ],
                );
              },
            ),
            Expanded(
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  final serverConfigs = settingsState.serverList;

                  return BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, chatState) {
                      final messages = chatState.displayMessages;

                      if (chatState.status == ChatStatus.initial ||
                          (chatState.status == ChatStatus.loading &&
                              messages.isEmpty)) {
                        // Show initial loading indicator if needed
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (messages.isEmpty &&
                          chatState.status != ChatStatus.loadingMessage) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FreePlanChip(),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                Wrap(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/logo.svg',
                                      width: 42,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'How\'s it going, Yash?',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                              color: Colors.white,
                                              fontFamily: 'Copernicus',
                                              fontWeight: FontWeight.w100),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 36),
                                BlocBuilder<McpCubit, McpState>(
                                  builder: (context, mcpState) {
                                    final connectedCount = mcpState
                                        .mcpClientState.connectedServerCount;
                                    return ChatTextField(
                                      controller: _textController,
                                      enabled: true,
                                      isLoading: false,
                                      isReplying: false,
                                      serversCount: connectedCount,
                                      isApiKeySet: chatState.isApiKeySet,
                                      onAdd: () {},
                                      onModify: () => _onModify(context),
                                      onSend: () => _sendMessage(context),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                const Wrap(
                                  alignment: WrapAlignment.center,
                                  runSpacing: 8,
                                  spacing: 8,
                                  children: [
                                    SuggestionChip(
                                        icon: 'assets/icons/write.svg',
                                        label: "Write"),
                                    SuggestionChip(
                                        icon: 'assets/icons/learn.svg',
                                        label: "Learn"),
                                    SuggestionChip(
                                        icon: 'assets/icons/code.svg',
                                        label: "Code"),
                                    SuggestionChip(
                                        icon: 'assets/icons/coffee.svg',
                                        label: "Life stuff"),
                                    SuggestionChip(
                                        icon: 'assets/icons/idea.svg',
                                        label: "Claude's choice"),
                                  ],
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16)
                            .copyWith(top: 20),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return MessageBubble(
                            message: message,
                            serverConfigs: serverConfigs, // Pass server configs
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            BlocBuilder<McpCubit, McpState>(builder: (context, mcpState) {
              return BlocBuilder<ChatCubit, ChatState>(
                buildWhen: (prev, curr) =>
                    prev.status != curr.status ||
                    prev.isApiKeySet != curr.isApiKeySet ||
                    prev.displayMessages.length != curr.displayMessages.length,
                builder: (context, chatState) {
                  final bool isLoading =
                      chatState.status == ChatStatus.loadingMessage ||
                          chatState.status == ChatStatus.messageStreaming;
                  final bool isEnabled = chatState.isApiKeySet && !isLoading;
                  final messages = chatState.displayMessages;
                  final connectedCount =
                      mcpState.mcpClientState.connectedServerCount;
                  return Opacity(
                    opacity: messages.isEmpty ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: messages.isEmpty,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16)
                            .copyWith(bottom: 8.0),
                        child: ChatTextField(
                            controller: _textController,
                            enabled: isEnabled,
                            isLoading: isLoading,
                            serversCount: connectedCount,
                            isReplying: messages.isNotEmpty,
                            isApiKeySet: chatState.isApiKeySet,
                            onAdd: () {},
                            onModify: () => _onModify(context),
                            onSend: () => _sendMessage(context)),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
