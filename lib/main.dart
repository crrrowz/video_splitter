import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:video_splitter/models/app_config_loader.dart';
import 'package:video_splitter/pages/home_page.dart';
import 'package:video_splitter/pages/loading_page.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VideoProcessorApp());
}

class VideoProcessorApp extends StatefulWidget {
  const VideoProcessorApp({Key? key}) : super(key: key);

  @override
  State<VideoProcessorApp> createState() => _VideoProcessorAppState();
}

class _VideoProcessorAppState extends State<VideoProcessorApp> with WidgetsBindingObserver {
  static const platform = MethodChannel('com.example.video_splitter/icons');
  late Future<AppConfig> _appConfigFuture;

  @override
  void initState() {
    super.initState();
    _appConfigFuture = AppConfig.load();
    WidgetsBinding.instance.addObserver(this);
    _updateAppIcon();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _updateAppIcon();
  }

  Future<void> _updateAppIcon() async {
    if (mounted) {
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      if (brightness == Brightness.dark) {
        await platform.invokeMethod('changeIcon', 'AppIcon-Dark');
      } else {
        await platform.invokeMethod('changeIcon', 'AppIcon-Light');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<AppConfig>(
        future: _appConfigFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final appConfig = snapshot.data!;
            return HomePage(appConfig: appConfig);
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error loading configuration: ${snapshot.error}'),
              ),
            );
          } else {
            return const LoadingPage();
          }
        },
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        cardColor: const Color(0xFFF0F0F0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF0F0F0),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.deepPurple,
          thumbColor: Colors.deepPurpleAccent,
          inactiveTrackColor: Colors.grey[300],
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.deepPurple,
          thumbColor: Colors.deepPurpleAccent,
          inactiveTrackColor: Colors.grey[800],
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
    );
  }
}