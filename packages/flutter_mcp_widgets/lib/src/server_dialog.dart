import 'package:flutter/material.dart';
import 'package:flutter_mcp_entities/flutter_mcp_entities.dart';
import 'package:flutter_mcp_widgets/src/common/gradient_border.dart';
import 'package:uuid/uuid.dart';

import 'common/custom_form_text_field.dart';
// Import your CustomFormTextField
// import 'path/to/custom_form_text_field.dart'; // Make sure path is correct

const _uuid = Uuid();

class _EnvVarPair {
  final String id;
  final TextEditingController keyController;
  final TextEditingController valueController;

  _EnvVarPair()
      : id = _uuid.v4(),
        keyController = TextEditingController(),
        valueController = TextEditingController();

  _EnvVarPair.fromMapEntry(MapEntry<String, String> entry)
      : id = _uuid.v4(),
        keyController = TextEditingController(text: entry.key),
        valueController = TextEditingController(text: entry.value);

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class ServerDialog extends StatefulWidget {
  final McpServerConfig? serverToEdit;
  final Function(
      String name,
      String command,
      String args,
      Map<String, String> envVars,
      bool isActive,
      ) onAddServer;
  final Function(McpServerConfig updatedServer) onUpdateServer;
  final Function(String) onError;

  const ServerDialog({
    super.key,
    this.serverToEdit,
    required this.onAddServer,
    required this.onUpdateServer,
    required this.onError,
  });

  @override
  State<ServerDialog> createState() => _ServerDialogState();
}

class _ServerDialogState extends State<ServerDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _commandController;
  late final TextEditingController _argsController;
  late bool _isActive;
  late List<_EnvVarPair> _envVars;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.serverToEdit != null;

  // Define consistent colors based on your theme
  late Color primaryTextColor;
  late Color secondaryTextColor;
  late Color subtleTextColor;
  late Color accentColor;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.serverToEdit?.name ?? '');
    _commandController =
        TextEditingController(text: widget.serverToEdit?.command ?? '');
    _argsController =
        TextEditingController(text: widget.serverToEdit?.args ?? '');
    _isActive = widget.serverToEdit?.isActive ?? false;
    _envVars = widget.serverToEdit?.customEnvironment.entries
        .map((e) => _EnvVarPair.fromMapEntry(e))
        .toList() ??
        [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize theme-dependent colors here
    primaryTextColor = Colors.white.withOpacity(0.85);
    secondaryTextColor = Colors.white.withOpacity(0.7);
    subtleTextColor = Colors.grey.withOpacity(0.5); // For less important hints
    accentColor = const Color(0xFFc96442);
  }


  @override
  void dispose() {
    _nameController.dispose();
    _commandController.dispose();
    _argsController.dispose();
    for (var pair in _envVars) {
      pair.dispose();
    }
    super.dispose();
  }

  void _addEnvVar() {
    setState(() {
      _envVars.add(_EnvVarPair());
    });
  }

  void _removeEnvVar(String id) {
    setState(() {
      final pairIndex = _envVars.indexWhere((p) => p.id == id);
      if (pairIndex != -1) {
        _envVars[pairIndex].dispose();
        _envVars.removeAt(pairIndex);
      }
    });
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      widget.onError('Please correct the errors in the form.');
      return;
    }

    final name = _nameController.text.trim();
    final command = _commandController.text.trim();
    final args = _argsController.text.trim();
    final Map<String, String> customEnvMap = {};
    bool envVarError = false;

    for (var pair in _envVars) {
      final key = pair.keyController.text.trim();
      final value = pair.valueController.text; // Values can have leading/trailing spaces
      if (key.isNotEmpty) {
        if (customEnvMap.containsKey(key)) {
          widget.onError('Error: Duplicate environment key "$key"');
          envVarError = true;
          break;
        }
        customEnvMap[key] = value;
      } else if (value.isNotEmpty) {
        // Optionally show warning or ignore
        // widget.onError('Warning: Environment variable with empty key ignored.');
      }
    }

    if (envVarError) return;

    Navigator.of(context).pop(); // Close dialog first

    if (_isEditing) {
      final updatedServer = widget.serverToEdit!.copyWith(
        name: name,
        command: command,
        args: args,
        isActive: _isActive,
        customEnvironment: customEnvMap,
      );
      widget.onUpdateServer(updatedServer);
    } else {
      widget.onAddServer(name, command, args, customEnvMap, _isActive);
    }
  }

  Widget _buildEnvVarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Custom Environment Variables',
              style: TextStyle(
                fontFamily: 'Copernicus', // Or 'StyreneB' if Copernicus is too heavy
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            // Use your CustomIconButton if available and styled, or a regular IconButton
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: accentColor, size: 24),
              tooltip: 'Add Variable',
              onPressed: _addEnvVar,
            ),
          ],
        ),
        Text(
          'Overrides system variables if names match.',
          style: TextStyle(fontSize: 11, color: subtleTextColor, fontFamily: 'StyreneB'),
        ),
        const SizedBox(height: 10),
        if (_envVars.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'No custom variables defined.',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: secondaryTextColor.withOpacity(0.6),
                  fontFamily: 'StyreneB'
              ),
            ),
          )
        else
          Column(
            children: List.generate(_envVars.length, (index) {
              final pair = _envVars[index];
              return Padding(
                key: ValueKey(pair.id), // Important for list item identity
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align with top of label
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomFormTextField( // Use the new custom field
                        controller: pair.keyController,
                        labelText: 'Variable Key',
                        hintText: 'e.g., MY_VAR',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: CustomFormTextField( // Use the new custom field
                        controller: pair.valueController,
                        labelText: 'Variable Value',
                        hintText: 'e.g., some_value',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 28.0), // Align with text field content
                      child: IconButton(
                        icon: Icon(Icons.remove_circle_outline,
                            color: Theme.of(context).colorScheme.error.withOpacity(0.8), size: 22),
                        tooltip: 'Remove Variable',
                        onPressed: () => _removeEnvVar(pair.id),
                        padding: const EdgeInsets.all(4), // Make tap target reasonable
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Using dialog's context theme for scaffoldBackgroundColor
    // The AlertDialog itself will handle this.

    return Padding( // Add padding around the content within the dialog
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _isEditing ? 'Edit MCP Server' : 'Add New MCP Server',
                style: TextStyle(
                  fontFamily: 'Copernicus',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 24),
              CustomFormTextField(
                controller: _nameController,
                labelText: 'Server Name*',
                hintText: 'e.g. fastmcp-server',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Name cannot be empty'
                    : null,
              ),
              const SizedBox(height: 18),
              CustomFormTextField(
                controller: _commandController,
                labelText: 'Server Command*',
                hintText: 'uv',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Command cannot be empty'
                    : null,
              ),
              const SizedBox(height: 18),
              CustomFormTextField(
                controller: _argsController,
                labelText: 'Server Arguments',
                hintText: 'run --httpx fastmcp run main.py',
                maxLines: 2, // Allow more space for args
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF30302d), // Match other inputs
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SwitchListTile(
                  title: Text('Connect Automatically', style: TextStyle(color: primaryTextColor, fontFamily: 'StyreneB', fontSize: 15)),
                  subtitle: Text('Applies when app starts or settings change', style: TextStyle(color: secondaryTextColor, fontFamily: 'StyreneB', fontSize: 11)),
                  value: _isActive,
                  onChanged: (bool value) => setState(() => _isActive = value),
                  activeColor: Colors.greenAccent, // Brighter green
                  inactiveThumbColor: Colors.grey.shade600,
                  inactiveTrackColor: Colors.grey.shade800.withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4), // Minimal internal padding
                ),
              ).gradientBorder(),
              const SizedBox(height: 24),
              const Divider(height: 1, color: Colors.white12),
              const SizedBox(height: 20),
              _buildEnvVarSection(),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: secondaryTextColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        textStyle: const TextStyle(fontFamily: 'StyreneB')
                    ),
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: const TextStyle(fontFamily: 'StyreneB', fontSize: 15)
                    ),
                    onPressed: _handleSubmit,
                    child: Text(_isEditing ? 'Save Changes' : 'Add Server'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the server dialog with the new modern styling
Future<void> showServerDialog({
  required BuildContext context,
  McpServerConfig? serverToEdit,
  required Function(
      String name,
      String command,
      String args,
      Map<String, String> envVars,
      bool isActive,
      ) onAddServer,
  required Function(McpServerConfig updatedServer) onUpdateServer,
  required Function(String) onError, // For form validation errors etc.
}) async {
  final ThemeData currentTheme = Theme.of(context); // Get theme from the calling context

  return showDialog<void>(
    context: context,
    barrierDismissible: true, // Allow dismissing by tapping outside for convenience
    builder: (BuildContext dialogContext) {
      // Provide the theme to the dialog's subtree if needed,
      // but AlertDialog should inherit it.
      return Theme( // Ensure dialog uses the correct theme context
        data: currentTheme,
        child: AlertDialog(
          backgroundColor: currentTheme.scaffoldBackgroundColor, // const Color(0xFF272724)
          elevation: 0, // Consistent with your settings dialog
          contentPadding: EdgeInsets.zero, // Content will have its own padding
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Standard dialog margins
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Match settings dialog
            side: const BorderSide(color: Colors.white12, width: 0.8), // Match settings dialog
          ),
          // Let the content determine its own size, but constrain it if it gets too large
          // The SingleChildScrollView inside ServerDialog will handle overflow.
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(dialogContext).size.width * 0.9, // Max 90% of screen width
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.85, // Max 85% of screen height
            ),
            child: ServerDialog( // Pass the actual dialog content widget
              serverToEdit: serverToEdit,
              onAddServer: onAddServer,
              onUpdateServer: onUpdateServer,
              onError: onError,
            ),
          ),
          // No actions here, ServerDialog has its own Cancel/Save buttons
        ),
      );
    },
  );
}