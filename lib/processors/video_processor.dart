import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/media_information.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path/path.dart' as p;

/// Base class for all video processors
abstract class VideoProcessor {
  final String inputPath;
  final String outputPath;

  VideoProcessor({
    required this.inputPath,
    required this.outputPath,
  });

  /// Build the FFmpeg command for this processor
  String buildCommand();

  /// Get the estimated duration for progress calculation
  Future<int> getVideoDurationMs() async {
    try {
      final session = await FFprobeKit.getMediaInformation(inputPath);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final mediaInfo = session.getMediaInformation();
        final durationString = mediaInfo?.getDuration();

        if (durationString != null) {
          final durationDouble = double.tryParse(durationString) ?? 0.0;
          return (durationDouble * 1000).toInt();
        }
      }
    } catch (e) {
      debugPrint("Error getting video duration: $e");
    }
    return 0;
  }

  /// Execute the FFmpeg command asynchronously
  Future<ProcessResult> execute({
    required Function(String) onLog,
    required Function(double) onProgress,
  }) async {
    final command = buildCommand();
    final durationMs = await getVideoDurationMs();

    debugPrint("Executing FFmpeg command: $command");

    final completer = Completer<ProcessResult>();

    FFmpegKit.executeAsync(
      command,
          (session) async {
        final returnCode = await session.getReturnCode();
        final logs = await session.getLogsAsString();

        if (ReturnCode.isSuccess(returnCode)) {
          completer.complete(ProcessResult(
            success: true,
            message: 'Processing completed successfully',
            logs: logs,
          ));
        } else if (ReturnCode.isCancel(returnCode)) {
          completer.complete(ProcessResult(
            success: false,
            message: 'Processing was cancelled',
            logs: logs,
          ));
        } else {
          completer.complete(ProcessResult(
            success: false,
            message: 'Processing failed with return code: ${await returnCode?.getValue() ?? 'unknown'}',
            logs: logs,
          ));
        }
      },
          (log) {
        onLog(log.getMessage());
      },
          (statistics) {
        if (durationMs > 0) {
          final currentTimeMs = statistics.getTime();
          final progress = (currentTimeMs / durationMs).clamp(0.0, 1.0);
          onProgress(progress);
        }
      },
    );

    return completer.future;
  }
}

/// Result of a video processing operation
class ProcessResult {
  final bool success;
  final String message;
  final String logs;

  ProcessResult({
    required this.success,
    required this.message,
    required this.logs,
  });
}

// No need for custom Completer - using Dart's built-in Completer from dart:async