import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'video_processor.dart';

/// Processor for detecting and removing solid background segments
class BackgroundRemovalProcessor extends VideoProcessor {
  final BackgroundColor backgroundColor;
  final double minDuration; // Minimum duration in seconds (e.g., 3.0)
  final double threshold; // Color similarity threshold (0.0-1.0)
  
  BackgroundRemovalProcessor({
    required super.inputPath,
    required super.outputPath,
    this.backgroundColor = BackgroundColor.white,
    this.minDuration = 3.0,
    this.threshold = 0.95,
  });

  @override
  String buildCommand() {
    // This is a complex multi-step process:
    // 1. Analyse video frame by frame to detect solid backgrounds
    // 2. Identify segments longer than minDuration
    // 3. Create a filter to remove those segments
    // 4. Apply the filter to create the final video
    
    return _buildBackgroundDetectionCommand();
  }

  /// Build command to detect and remove solid background segments
  String _buildBackgroundDetectionCommand() {
    // Get the color value based on background type
    final String colorFilter = _getColorDetectionFilter();
    
    // Use blackdetect/freezedetect as a base, then filter by color
    // This approach detects static frames and checks if they match the target color
    
    final videoFilters = [
      colorFilter,
      'freezedetect=n=$threshold:d=$minDuration', // Detect static frames
    ].join(',');

    // First pass: detect segments (output to null, we need to parse logs)
    return '-y -i "$inputPath" '
        '-vf "$videoFilters" '
        '-f null -';
    
    // Note: This is the detection phase. The actual removal would require:
    // 1. Parsing the FFmpeg output to find segment timestamps
    // 2. Creating a filter script to cut out those segments
    // 3. Running a second FFmpeg command with the filter script
    // This needs additional Dart code to process the results
  }

  /// Get the appropriate color detection filter based on background type
  String _getColorDetectionFilter() {
    switch (backgroundColor) {
      case BackgroundColor.white:
        // Detect white pixels (RGB close to 255,255,255)
        return 'geq=lum_expr=\'if(gt(lum(X,Y),240),255,0)\':cb_expr=128:cr_expr=128';
      
      case BackgroundColor.black:
        // Use built-in blackdetect
        return 'blackdetect=d=$minDuration:pix_th=0.10';
      
      case BackgroundColor.green:
        // Detect green screen (chroma key green)
        return 'colorkey=0x00FF00:${threshold}:0.1';
    }
  }

  /// Alternative approach: Frame-by-frame analysis with scene detection
  String _buildSceneDetectionCommand() {
    // Use scene detection to find cuts, then analyse each scene
    // for solid backgrounds
    
    final String colorFilter = _getColorDetectionFilter();
    
    return '-y -i "$inputPath" '
        '-vf "select=\'gt(scene,0.3)\',$colorFilter,metadata=print:file=-" '
        '-vsync vfr '
        '-f null -';
  }

  /// Build final removal command (to be called after detection phase)
  String buildRemovalCommand(List<TimeSegment> segmentsToRemove) {
    if (segmentsToRemove.isEmpty) {
      // No segments to remove, just copy
      return '-y -i "$inputPath" -c copy "$outputPath"';
    }

    // Build complex filter to select only the segments we want to keep
    final List<String> selectStatements = [];
    double currentTime = 0.0;
    
    for (var segment in segmentsToRemove) {
      if (segment.startTime > currentTime) {
        // Add the segment before this removed section
        selectStatements.add('between(t,${currentTime},${segment.startTime})');
      }
      currentTime = segment.endTime;
    }
    
    // Add the final segment after the last removed section
    selectStatements.add('gte(t,${currentTime})');
    
    final String selectFilter = selectStatements.join('+');
    
    return '-y -i "$inputPath" '
        '-vf "select=\'$selectFilter\',setpts=N/FRAME_RATE/TB" '
        '-af "aselect=\'$selectFilter\',asetpts=N/SR/TB" '
        '-c:v h264_mediacodec -b:v 4M '
        '-c:a aac '
        '"$outputPath"';
  }
}

/// Enum for background colors
enum BackgroundColor {
  white,
  black,
  green,
}

/// Represents a time segment in the video
class TimeSegment {
  final double startTime; // in seconds
  final double endTime;   // in seconds
  
  TimeSegment({
    required this.startTime,
    required this.endTime,
  });
  
  double get duration => endTime - startTime;
  
  @override
  String toString() => 'TimeSegment(${startTime}s - ${endTime}s, duration: ${duration}s)';
}