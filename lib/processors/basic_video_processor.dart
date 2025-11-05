import 'video_processor.dart';
import '../models/app_settings.dart';

/// Basic video processor for speed adjustment, filters, and splitting
class BasicVideoProcessor extends VideoProcessor {
  final AppSettings settings;
  
  BasicVideoProcessor({
    required super.inputPath,
    required super.outputPath,
    required this.settings,
  });

  @override
  String buildCommand() {
    // Check if any re-encoding is needed
    final bool requiresReEncode =
        settings.speed != 1.0 ||
        settings.grayscaleFilter ||
        settings.removeAudio;

    if (requiresReEncode) {
      return _buildReEncodeCommand();
    } else {
      return _buildStreamCopyCommand();
    }
  }

  /// Build command with re-encoding (for filters and speed changes)
  String _buildReEncodeCommand() {
    final List<String> vfFilters = [];
    
    // Speed filter
    vfFilters.add('setpts=${(1.0 / settings.speed).toStringAsFixed(2)}*PTS');
    
    // Grayscale filter
    if (settings.grayscaleFilter) {
      vfFilters.add('format=gray');
    }
    
    final String vfCommand = vfFilters.join(',');
    final String audioCommand = settings.removeAudio ? '-an' : '';
    
    // Use hardware acceleration
    const String videoCodec = '-c:v h264_mediacodec';
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

  /// Build command with stream copy (fastest, no re-encoding)
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
}