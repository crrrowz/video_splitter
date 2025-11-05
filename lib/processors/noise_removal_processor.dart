import 'dart:io';
import 'package:path/path.dart' as p;
import 'video_processor.dart';

/// Processor for detecting and removing noisy audio segments
class NoiseRemovalProcessor extends VideoProcessor {
  final double noiseThreshold; // in dB (e.g., -30dB)
  final double minSilenceDuration; // in seconds (e.g., 0.5)

  NoiseRemovalProcessor({
    required super.inputPath,
    required super.outputPath,
    this.noiseThreshold = -30.0,
    this.minSilenceDuration = 0.5,
  });

  @override
  String buildCommand() {
    return _buildNoiseGateCommand();
  }

  /// One-pass noise reduction with highpass/lowpass + silenceremove
  String _buildNoiseGateCommand() {
    final audioFilters = [
      'highpass=f=200', // Remove frequencies below 200Hz
      'lowpass=f=3000', // Remove frequencies above 3000Hz
      'silenceremove='
          'start_periods=1:'
          'start_duration=0:'
          'start_threshold=$noiseThreshold:'
          'detection=peak:'
          'stop_periods=-1:'
          'stop_duration=$minSilenceDuration:'
          'stop_threshold=$noiseThreshold',
    ].join(',');

    return '-y -i "$inputPath" '
        '-af "$audioFilters" '
        '-c:v copy '
        '-c:a aac -b:a 192k '
        '"$outputPath"';
  }

  /// Optional: Two-pass approach (advanced)
  String buildSegmentRemovalCommand() {
    // First pass: detect silent/noisy segments
    return '-y -i "$inputPath" '
        '-af silencedetect=n=$noiseThreshold:d=$minSilenceDuration '
        '-f null -';
    // Note: You would need to parse this output to generate
    // an EDL for the second pass to cut out noisy segments.
  }
}
