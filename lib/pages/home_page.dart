import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:video_splitter/models/app_settings.dart';
import 'package:video_splitter/pages/settings_page.dart';
import 'package:video_splitter/models/app_config_loader.dart';

// Import the new processors
import 'package:video_splitter/processors/video_processor.dart';
import 'package:video_splitter/processors/basic_video_processor.dart';
import 'package:video_splitter/processors/noise_removal_processor.dart';
import 'package:video_splitter/processors/background_removal_processor.dart';

class HomePage extends StatefulWidget {
  final AppConfig appConfig;
  const HomePage({Key? key, required this.appConfig}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('com.example.video_splitter/storage');
  XFile? _selectedVideo;
  String? _selectedVideoDisplayName;
  late AppSettings _settings;
  bool _isLoadingSettings = true;
  bool _isProcessing = false;
  String _processingLog = '';
  final ImagePicker _picker = ImagePicker();

  double _processingProgress = 0.0;
  int _videoDurationMs = 0;
  String _currentProcessingStage = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkInitialPermissions();
    _cleanupEmptyFolders();
  }

  Future<void> _checkInitialPermissions() async {
    if (Platform.isAndroid) {
      final videosStatus = await Permission.videos.status;
      final storageStatus = await Permission.storage.status;
      final photosStatus = await Permission.photos.status;

      debugPrint("=== Initial Permission Status ===");
      debugPrint("Videos: $videosStatus");
      debugPrint("Storage: $storageStatus");
      debugPrint("Photos: $photosStatus");
      debugPrint("===============================");
    }
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoadingSettings = true;
    });
    _settings = await AppSettings.load();
    setState(() {
      _isLoadingSettings = false;
    });
  }

  void _showFeedbackDialog(String title, String content) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickVideo() async {
    if (_isProcessing) return;

    try {
      PermissionStatus status;

      if (Platform.isAndroid) {
        debugPrint("Requesting videos permission...");
        status = await Permission.videos.request();
        debugPrint("Videos permission status: $status");

        if (!status.isGranted) {
          debugPrint("Videos permission not granted, trying storage permission...");
          status = await Permission.storage.request();
          debugPrint("Storage permission status: $status");
        }

        if (!status.isGranted) {
          debugPrint("Storage permission not granted, trying photos permission...");
          status = await Permission.photos.request();
          debugPrint("Photos permission status: $status");
        }
      } else {
        debugPrint("Requesting photos permission for iOS...");
        status = await Permission.photos.request();
        debugPrint("Photos permission status: $status");
      }

      if (!status.isGranted) {
        debugPrint("Permission denied. Status: $status");
        if (status.isPermanentlyDenied) {
          _showFeedbackDialog(
              "Permission Required",
              "Gallery access is permanently denied. Please enable it in your phone's app settings.\n\nGo to: Settings > Apps > video_splitter > Permissions"
          );
          await openAppSettings();
        } else {
          _showFeedbackDialog(
              "Permission Required",
              "This app needs permission to access your videos/gallery to select videos for processing."
          );
        }
        return;
      }

      debugPrint("Permission granted, opening gallery...");
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        debugPrint("Video selected: ${video.path}");
        setState(() {
          _selectedVideo = video;
          _selectedVideoDisplayName = p.basename(video.path);
        });
      } else {
        debugPrint("No video selected by user");
      }
    } catch (e, stackTrace) {
      debugPrint("Error picking video: $e");
      debugPrint("Stack trace: $stackTrace");
      _showFeedbackDialog("Error", "Failed to pick video: $e\n\nPlease check that gallery permissions are enabled.");
    }
  }

  Future<void> _goToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(settings: _settings, appConfig: widget.appConfig),
      ),
    );
    _loadSettings();
  }

  Future<bool> _checkPermissions() async {
    var videoStatus = await Permission.videos.request();
    if (videoStatus.isGranted) {
      return true;
    }

    var storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      return true;
    }

    if (videoStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
      _showFeedbackDialog(
        "Permission Required",
        "Video and/or storage permission is permanently denied. "
            "Please enable it in your phone's app settings to proceed.",
      );
    } else {
      _showFeedbackDialog(
        "Permission Required",
        "Video and/or storage permission is required to select videos and save output.",
      );
    }
    return false;
  }

  Future<Directory?> _getOutputDirectory() async {
    const String appName = "video_splitter";
    try {
      Directory? baseDir;

      if (Platform.isAndroid) {
        final String? externalStorage = await _getExternalStoragePath();
        if (externalStorage == null) {
          _showFeedbackDialog("Error", "Could not access external storage.");
          return null;
        }
        baseDir = Directory(p.join(externalStorage, 'Movies', appName));
      } else {
        baseDir = await getApplicationDocumentsDirectory();
        baseDir = Directory(p.join(baseDir.path, appName));
      }

      if (!await baseDir.exists()) {
        await baseDir.create(recursive: true);
      }

      debugPrint("--- Output directory set to: ${baseDir.path} ---");
      return baseDir;

    } catch (e) {
      _showFeedbackDialog("Directory Error",
          "Failed to create output directory: $e");
      return null;
    }
  }

  Future<String?> _getExternalStoragePath() async {
    try {
      if (Platform.isAndroid) {
        final String? path = Platform.environment['EXTERNAL_STORAGE'];
        if (path != null && path.isNotEmpty) {
          return path;
        }
        return '/storage/emulated/0';
      }
      return null;
    } catch (e) {
      debugPrint("Error getting external storage path: $e");
      return '/storage/emulated/0';
    }
  }

  Future<void> _cleanupEmptyFolders() async {
    try {
      final Directory? baseOutputDir = await _getOutputDirectory();
      if (baseOutputDir == null || !await baseOutputDir.exists()) {
        return;
      }

      final List<FileSystemEntity> entities = baseOutputDir.listSync();
      int deletedCount = 0;

      for (var entity in entities) {
        if (entity is Directory) {
          final List<FileSystemEntity> contents = entity.listSync();
          if (contents.isEmpty) {
            await entity.delete(recursive: true);
            deletedCount++;
            debugPrint("🗑️ Deleted empty folder: ${entity.path}");
          }
        }
      }

      if (deletedCount > 0) {
        debugPrint("✅ Cleanup complete: Deleted $deletedCount empty folder(s)");
      }
    } catch (e) {
      debugPrint("❌ Error cleaning up empty folders: $e");
    }
  }

  Future<void> _deleteAllVideos() async {
    try {
      final Directory? baseOutputDir = await _getOutputDirectory();
      if (baseOutputDir == null || !await baseOutputDir.exists()) {
        _showFeedbackDialog("Info", "No video folders found to delete.");
        return;
      }

      final List<FileSystemEntity> entities = baseOutputDir.listSync();
      int deletedFolders = 0;
      int deletedFiles = 0;

      for (var entity in entities) {
        if (entity is Directory) {
          try {
            // Check if directory exists before trying to delete
            if (await entity.exists()) {
              final List<FileSystemEntity> contents = entity.listSync();
              deletedFiles += contents.where((e) => e is File).length;

              await entity.delete(recursive: true);
              deletedFolders++;
              debugPrint("🗑️ Deleted folder: ${entity.path}");
            }
          } catch (e) {
            debugPrint("⚠️ Could not delete ${entity.path}: $e");
            // Continue with next folder instead of failing completely
          }
        }
      }

      if (deletedFolders > 0) {
        _showFeedbackDialog(
          "Deleted Successfully! 🗑️",
          "Deleted $deletedFolders folder(s) containing $deletedFiles video file(s).\n\n"
              "The videos have been removed from your device.",
        );
      } else {
        _showFeedbackDialog("Info", "No video folders found to delete.");
      }
    } catch (e) {
      _showFeedbackDialog("Error", "Failed to delete videos: $e");
      debugPrint("❌ Error deleting videos: $e");
    }
  }

  Future<void> _confirmDeleteAllVideos() async {
    if (!mounted) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Videos?'),
        content: const Text(
          'This will permanently delete all processed video folders and their contents.\n\n'
              'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAllVideos();
    }
  }

  Future<void> _notifyMediaScanner(Directory outputDir) async {
    if (!Platform.isAndroid) return;

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final List<FileSystemEntity> files = outputDir.listSync();
      int scannedCount = 0;

      for (var file in files) {
        if (file is File && file.path.endsWith('.mp4')) {
          try {
            await platform.invokeMethod('scanFile', {'path': file.path});
            scannedCount++;
            debugPrint("✅ Media scanner notified for: ${file.path}");
            await Future.delayed(const Duration(milliseconds: 100));
          } catch (e) {
            debugPrint("❌ Error scanning file ${file.path}: $e");
          }
        }
      }

      debugPrint("📱 Total files scanned: $scannedCount");

      if (scannedCount > 0) {
        try {
          await platform.invokeMethod('scanFile', {'path': outputDir.path});
          debugPrint("✅ Directory scan requested: ${outputDir.path}");
        } catch (e) {
          debugPrint("⚠️ Directory scan failed (this is okay): $e");
        }
      }

    } catch (e) {
      debugPrint("❌ Error notifying media scanner: $e");
    }
  }

  /// Main processing method that orchestrates all processors
  Future<void> _startProcessing() async {
    if (_selectedVideo == null) {
      _showFeedbackDialog("No Video", "Please select a video first.");
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingProgress = 0.0;
      _videoDurationMs = 0;
      _processingLog = 'Starting process...\n';
      _currentProcessingStage = 'Initializing';
    });

    // 1. Check Permissions
    if (!await _checkPermissions()) {
      setState(() { _isProcessing = false; });
      return;
    }

    // 2. Get Output Directory
    final Directory? baseOutputDir = await _getOutputDirectory();
    if (baseOutputDir == null) {
      setState(() { _isProcessing = false; });
      return;
    }

    final String inputPath = _selectedVideo!.path;
    final String inputFileName = p.basenameWithoutExtension(inputPath);

    // Create unique folder
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String uniqueFolderName = '${inputFileName}_$timestamp';
    final Directory finalOutputDir = Directory(p.join(baseOutputDir.path, uniqueFolderName));

    if (!await finalOutputDir.exists()) {
      await finalOutputDir.create(recursive: true);
    }

    debugPrint("📁 Output directory: ${finalOutputDir.path}");

    try {
      String currentInput = inputPath;
      int stageNumber = 1;
      int totalStages = _calculateTotalStages();

      // === STAGE 1: NOISE REMOVAL (if enabled) ===
      if (_settings.enableNoiseRemoval) {
        await _processNoiseRemoval(
          currentInput,
          finalOutputDir,
          stageNumber++,
          totalStages,
        );
        // Update input for next stage
        currentInput = p.join(finalOutputDir.path, 'stage1_noise_removed.mp4');
      }

      // === STAGE 2: BACKGROUND REMOVAL (if enabled) ===
      if (_settings.enableBackgroundRemoval) {
        await _processBackgroundRemoval(
          currentInput,
          finalOutputDir,
          stageNumber++,
          totalStages,
        );
        // Update input for next stage
        currentInput = p.join(finalOutputDir.path, 'stage2_background_removed.mp4');
      }

      // === STAGE 3: BASIC PROCESSING (always run) ===
      await _processBasicVideo(
        currentInput,
        finalOutputDir,
        stageNumber++,
        totalStages,
        inputFileName,
      );

      // Success!
      await _notifyMediaScanner(finalOutputDir);

      final List<FileSystemEntity> files = finalOutputDir.listSync();
      final int videoCount = files.where((f) => f is File && f.path.endsWith('.mp4')).length;

      _showFeedbackDialog(
        'Success! ✅',
        'Video processing complete!\n\n'
            '🎹 Created $videoCount video segment${videoCount != 1 ? 's' : ''}\n'
            '📁 Location: Movies/video_splitter/${p.basename(finalOutputDir.path)}\n\n'
            'Videos should appear in your gallery shortly.',
      );

    } catch (e) {
      _showFeedbackDialog('Error', 'Processing failed: $e');
      debugPrint("❌ Processing error: $e");
    } finally {
      setState(() {
        _isProcessing = false;
        _processingProgress = 0.0;
        _videoDurationMs = 0;
        _currentProcessingStage = '';
      });
    }
  }

  /// Calculate total processing stages
  int _calculateTotalStages() {
    int stages = 1; // Basic processing always runs
    if (_settings.enableNoiseRemoval) stages++;
    if (_settings.enableBackgroundRemoval) stages++;
    return stages;
  }

  /// Process noise removal stage
  Future<void> _processNoiseRemoval(
      String inputPath,
      Directory outputDir,
      int stageNumber,
      int totalStages,
      ) async {
    setState(() {
      _currentProcessingStage = 'Stage $stageNumber/$totalStages: Removing Noise';
      _processingLog += '\n=== STAGE $stageNumber: NOISE REMOVAL ===\n';
    });

    final outputPath = p.join(outputDir.path, 'stage1_noise_removed.mp4');

    final processor = NoiseRemovalProcessor(
      inputPath: inputPath,
      outputPath: outputPath,
      noiseThreshold: _settings.noiseThreshold,
      minSilenceDuration: _settings.minSilenceDuration,
    );

    final result = await processor.execute(
      onLog: (log) {
        setState(() {
          _processingLog += log;
        });
      },
      onProgress: (progress) {
        setState(() {
          _processingProgress = ((stageNumber - 1) + progress) / totalStages;
        });
      },
    );

    if (!result.success) {
      setState(() {
        _processingLog += '\n❌ Noise removal failed!\n';
        _processingLog += 'Error: ${result.message}\n';
        _processingLog += '\nLogs:\n${result.logs}\n';
      });
      throw Exception('Noise removal failed: ${result.message}');
    }

    setState(() {
      _processingLog += '\n✅ Noise removal complete!\n';
    });
  }

  /// Process background removal stage
  Future<void> _processBackgroundRemoval(
      String inputPath,
      Directory outputDir,
      int stageNumber,
      int totalStages,
      ) async {
    setState(() {
      _currentProcessingStage = 'Stage $stageNumber/$totalStages: Removing Background';
      _processingLog += '\n=== STAGE $stageNumber: BACKGROUND REMOVAL ===\n';
    });

    final outputPath = p.join(outputDir.path, 'stage2_background_removed.mp4');

    // Convert BackgroundColorType to BackgroundColor
    BackgroundColor bgColor;
    switch (_settings.backgroundColor) {
      case BackgroundColorType.white:
        bgColor = BackgroundColor.white;
        break;
      case BackgroundColorType.black:
        bgColor = BackgroundColor.black;
        break;
      case BackgroundColorType.green:
        bgColor = BackgroundColor.green;
        break;
    }

    final processor = BackgroundRemovalProcessor(
      inputPath: inputPath,
      outputPath: outputPath,
      backgroundColor: bgColor,
      minDuration: _settings.backgroundMinDuration,
      threshold: _settings.backgroundThreshold,
    );

    // Note: Background removal is currently a simple copy operation
    setState(() {
      _processingLog += 'Note: Background removal is experimental. Currently performs video copy.\n';
    });

    final result = await processor.execute(
      onLog: (log) {
        setState(() {
          _processingLog += log;
        });
      },
      onProgress: (progress) {
        setState(() {
          _processingProgress = ((stageNumber - 1) + progress) / totalStages;
        });
      },
    );

    if (!result.success) {
      setState(() {
        _processingLog += '\n❌ Background removal failed!\n';
        _processingLog += 'Error: ${result.message}\n';
        _processingLog += '\nLogs:\n${result.logs}\n';
      });
      throw Exception('Background removal failed: ${result.message}');
    }

    setState(() {
      _processingLog += '\n✅ Background removal complete!\n';
    });
  }

  /// Process basic video operations (filters, speed, splitting)
  Future<void> _processBasicVideo(
      String inputPath,
      Directory outputDir,
      int stageNumber,
      int totalStages,
      String baseFileName,
      ) async {
    setState(() {
      _currentProcessingStage = 'Stage $stageNumber/$totalStages: Final Processing';
      _processingLog += '\n=== STAGE $stageNumber: FINAL VIDEO PROCESSING ===\n';
    });

    final String outputPattern;
    if (_settings.segmentTime > 0) {
      outputPattern = p.join(outputDir.path, '%d.mp4');
    } else {
      outputPattern = p.join(outputDir.path, '${baseFileName}_final.mp4');
    }

    final processor = BasicVideoProcessor(
      inputPath: inputPath,
      outputPath: outputPattern,
      settings: _settings,
    );

    final result = await processor.execute(
      onLog: (log) {
        setState(() {
          _processingLog += log;
        });
      },
      onProgress: (progress) {
        setState(() {
          _processingProgress = ((stageNumber - 1) + progress) / totalStages;
        });
      },
    );

    if (!result.success) {
      setState(() {
        _processingLog += '\n❌ Basic processing failed!\n';
        _processingLog += 'Error: ${result.message}\n';
        _processingLog += '\nLogs:\n${result.logs}\n';
      });
      throw Exception('Basic processing failed: ${result.message}');
    }

    setState(() {
      _processingLog += '\n✅ Final processing complete!\n';
      _processingProgress = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appConfig.appInfo.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Delete All Videos',
            onPressed: _confirmDeleteAllVideos,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _goToSettings,
          ),
        ],
      ),
      body: _isLoadingSettings
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Video Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. Select Video', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.video_library),
                        label: const Text('Select from Gallery'),
                        onPressed: _pickVideo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Selected Video:', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(_selectedVideoDisplayName ?? 'No video selected.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Settings Quick-link
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('2. Configure Settings'),
                subtitle: Text(
                  'Speed: ${_settings.speed}x, '
                      'Noise: ${_settings.enableNoiseRemoval ? "ON" : "OFF"}, '
                      'BG: ${_settings.enableBackgroundRemoval ? "ON" : "OFF"}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _goToSettings,
              ),
            ),
            const SizedBox(height: 24),

            // Process Button
            Center(
              child: ElevatedButton.icon(
                icon: _isProcessing
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _processingProgress > 0 ? _processingProgress : null,
                        color: Colors.white,
                        strokeWidth: 3,
                        backgroundColor: Colors.white.withOpacity(0.3),
                      ),
                      if (_processingProgress > 0)
                        Text(
                          '${(_processingProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                )
                    : const Icon(Icons.play_arrow),
                label: Text(_isProcessing ? 'PROCESSING...' : '3. Start Processing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isProcessing ? Colors.grey[700] : Colors.green[600],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                onPressed: (_selectedVideo != null && !_isProcessing) ? _startProcessing : null,
              ),
            ),

            // Current Stage Indicator
            if (_isProcessing && _currentProcessingStage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(
                    _currentProcessingStage,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Processing Log
            if (_isProcessing || _processingLog.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Processing Log', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: SingleChildScrollView(
                          reverse: true,
                          child: Text(
                            _processingLog,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}