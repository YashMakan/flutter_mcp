import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mcp/pages/chat_screen.dart';
import 'package:flutter_mcp_state/flutter_mcp_state.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:window_manager/window_manager.dart';

import 'di/injection_container.dart' as di;


Future<void> adjustTrafficLights() async {
  try {
    const platform = MethodChannel('com.example.flutter_mcp');
    await platform.invokeMethod('adjustTrafficLights');
  } on PlatformException catch (e) {
    print("Failed to adjust traffic lights: ${e.message}");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: ' ',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await adjustTrafficLights();
  });

  await di.initDi();
  Bloc.observer = TalkerBlocObserver(
    settings: const TalkerBlocLoggerSettings(
      enabled: true,
      printEventFullData: false,
      printStateFullData: false,
      printChanges: true,
      printClosings: true,
      printCreations: true,
      printEvents: true,
      printTransitions: true,
    ),
  );

  di.sl<McpCubit>().syncConnections();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (_) => di.sl<SettingsCubit>()..loadInitialSettings(),
        ),
        BlocProvider<McpCubit>(
            create: (_) => di.sl<McpCubit>()..listenToMcpUpdates()),
        BlocProvider<ChatCubit>(
            create: (_) => di.sl<ChatCubit>()..initialize()),
      ],
      child: MaterialApp(
        title: '',
        theme: ThemeData(
          primaryColor: const Color(0xFF844c38),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
          fontFamily: 'StyreneB',
          scaffoldBackgroundColor: const Color(0xFF272724),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const ChatPage()
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
