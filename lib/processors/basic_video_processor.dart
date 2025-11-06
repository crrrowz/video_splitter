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
    // إعادة التشفير ضروري فقط إذا:
    // - سرعة != 1.0
    // - فلتر رمادي مفعل
    final bool requiresVideoReEncode =
        settings.speed != 1.0 || settings.grayscaleFilter;

    // إزالة الصوت فقط لا تحتاج لإعادة ترميز الفيديو
    final bool requiresAudioRemovalOnly =
        settings.removeAudio && !requiresVideoReEncode;

    if (requiresVideoReEncode) {
      return _buildReEncodeCommand();
    } else if (requiresAudioRemovalOnly) {
      return _buildAudioRemovalCommand();
    } else {
      return _buildStreamCopyCommand();
    }
  }

  /// إعادة التشفير فقط عند الحاجة
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

  /// نسخ مباشر سريع جدًا عند عدم وجود تغييرات
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

  /// إزالة الصوت فقط، نسخ الفيديو مباشرة
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
}
