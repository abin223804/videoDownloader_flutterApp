import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'core/theme/app_theme.dart';
import 'features/downloader/presentation/screens/home_screen.dart';
import 'features/settings/presentation/screens/disclaimer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Downloader
  await FlutterDownloader.initialize(
    debug: true, 
    ignoreSsl: true, 
  );

  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  runApp(
    ProviderScope(
      child: const MediaSaverApp(),
    ),
  );
}

class MediaSaverApp extends ConsumerWidget {
  const MediaSaverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MediaSaver Pro',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const DisclaimerScreen(),
    );
  }
}
