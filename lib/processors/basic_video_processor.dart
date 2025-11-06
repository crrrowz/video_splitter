import 'video_processor.dart';
import '../models/app_settings.dart';

/// Optimized video processor: stream copy when possible, re-encode only if needed
class BasicVideoProcessor extends VideoProcessor {
  final AppSettings settings;

  BasicVideoProcessor({
    required super.inputPath,
    required super.outputPath,
    required this.settings,
  });

  @override
  String buildCommand() {
    // Re-encode video only if:
    // - speed != 1.0
    // - grayscale filter is applied
    final bool requiresVideoReEncode =
        settings.speed != 1.0 || settings.grayscaleFilter;

    // Audio removal only does not need full video re-encode
    final bool requiresAudioRemovalOnly =
        settings.removeAudio && !requiresVideoReEncode;

    if (requiresVideoReEncode) {
      return _buildReEncodeCommand();
    } else if (settings.forceH264) {
      return _buildH264ForceCommand();
    } else if (requiresAudioRemovalOnly) {
      return _buildAudioRemovalCommand();
    } else {
      return _buildStreamCopyCommand();
    }
  }

  /// Re-encode video with optional speed and grayscale filters
  String _buildReEncodeCommand() {
    final List<String> vfFilters = [];

    if (settings.speed != 1.0) {
      vfFilters.add('setpts=${(1.0 / settings.speed).toStringAsFixed(2)}*PTS');
    }

    if (settings.grayscaleFilter) {
      vfFilters.add('format=gray');
    }

    final String vfCommand = vfFilters.join(',');
    final String audioCommand = settings.removeAudio ? '-an' : '';

    // Use libx264 for better quality control
    const String videoCodec = '-c:v libx264 -preset veryfast -crf 23';
    const String audioCodec = '-c:a aac';

    if (settings.segmentTime > 0) {
      return '-y -i "$inputPath" '
          '-vf "$vfCommand" '
          '$audioCommand '
          '$videoCodec -b:v ${settings.videoBitrate} '
          '$audioCodec '
          '-f segment -segment_time ${settings.segmentTime} '
          '-reset_timestamps 1 -map 0 '
          '"$outputPath"';
    } else {
      return '-y -i "$inputPath" '
          '-vf "$vfCommand" '
          '$audioCommand '
          '$videoCodec -b:v ${settings.videoBitrate} '
          '$audioCodec '
          '-map 0 '
          '"$outputPath"';
    }
  }

  /// Fastest option: copy video/audio streams directly
  String _buildStreamCopyCommand() {
    if (settings.segmentTime > 0) {
      return '-y -i "$inputPath" '
          '-c copy '
          '-f segment -segment_time ${settings.segmentTime} '
          '-reset_timestamps 1 -map 0 '
          '-avoid_negative_ts 1 '
          '"$outputPath"';
    } else {
      return '-y -i "$inputPath" '
          '-c copy '
          '-map 0 '
          '"$outputPath"';
    }
  }

  /// Remove audio only, copy video stream
  String _buildAudioRemovalCommand() {
    if (settings.segmentTime > 0) {
      return '-y -i "$inputPath" '
          '-c:v copy '
          '-an '
          '-f segment -segment_time ${settings.segmentTime} '
          '-reset_timestamps 1 -map 0 '
          '"$outputPath"';
    } else {
      return '-y -i "$inputPath" '
          '-c:v copy '
          '-an '
          '-map 0 '
          '"$outputPath"';
    }
  }

  /// Force H.264 re-encode with controlled quality and copied audio
  String _buildH264ForceCommand() {
    // Use libx264 instead of h264_mediacodec for better quality
    const String videoCodec = '-c:v libx264 -preset veryfast -crf 23';
    const String audioCodec = '-c:a copy';

    if (settings.segmentTime > 0) {
      return '-y -i "$inputPath" '
          '$videoCodec '
          '$audioCodec '
          '-f segment -segment_time ${settings.segmentTime} '
          '-reset_timestamps 1 -map 0 '
          '"$outputPath"';
    } else {
      return '-y -i "$inputPath" '
          '$videoCodec '
          '$audioCodec '
          '-map 0 '
          '"$outputPath"';
    }
  }
}
