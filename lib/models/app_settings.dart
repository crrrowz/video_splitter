import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  // Basic settings
  int segmentTime;
  double speed;
  bool removeAudio;
  String videoBitrate;
  bool grayscaleFilter;
  bool forceH264;
  
  // NEW: Noise removal settings
  bool enableNoiseRemoval;
  double noiseThreshold; // in dB (e.g., -30.0)
  double minSilenceDuration; // in seconds (e.g., 0.5)
  
  // NEW: Background removal settings
  bool enableBackgroundRemoval;
  BackgroundColorType backgroundColor;
  double backgroundMinDuration; // Minimum duration in seconds (e.g., 3.0)
  double backgroundThreshold; // Similarity threshold (0.0-1.0)

  AppSettings({
    // Basic settings defaults
    this.segmentTime = 60,
    this.speed = 1.0,
    this.removeAudio = false,
    this.videoBitrate = '4M',
    this.grayscaleFilter = false,
    this.forceH264 = false,
    
    // Noise removal defaults
    this.enableNoiseRemoval = false,
    this.noiseThreshold = -30.0,
    this.minSilenceDuration = 0.5,
    
    // Background removal defaults
    this.enableBackgroundRemoval = false,
    this.backgroundColor = BackgroundColorType.white,
    this.backgroundMinDuration = 3.0,
    this.backgroundThreshold = 0.95,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      // Basic settings
      segmentTime: json['segment_time'] as int? ?? 60,
      speed: (json['speed'] as num? ?? 1.0).toDouble(),
      removeAudio: json['remove_audio'] as bool? ?? false,
      videoBitrate: json['video_bitrate'] as String? ?? '4M',
      grayscaleFilter: json['grayscale_filter'] as bool? ?? false,
      forceH264: json['force_h264'] as bool? ?? false,
      
      // Noise removal settings
      enableNoiseRemoval: json['enable_noise_removal'] as bool? ?? false,
      noiseThreshold: (json['noise_threshold'] as num? ?? -30.0).toDouble(),
      minSilenceDuration: (json['min_silence_duration'] as num? ?? 0.5).toDouble(),
      
      // Background removal settings
      enableBackgroundRemoval: json['enable_background_removal'] as bool? ?? false,
      backgroundColor: BackgroundColorType.values[json['background_color'] as int? ?? 0],
      backgroundMinDuration: (json['background_min_duration'] as num? ?? 3.0).toDouble(),
      backgroundThreshold: (json['background_threshold'] as num? ?? 0.95).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Basic settings
      'segment_time': segmentTime,
      'speed': speed,
      'remove_audio': removeAudio,
      'video_bitrate': videoBitrate,
      'grayscale_filter': grayscaleFilter,
      'force_h264': forceH264,
      
      // Noise removal settings
      'enable_noise_removal': enableNoiseRemoval,
      'noise_threshold': noiseThreshold,
      'min_silence_duration': minSilenceDuration,
      
      // Background removal settings
      'enable_background_removal': enableBackgroundRemoval,
      'background_color': backgroundColor.index,
      'background_min_duration': backgroundMinDuration,
      'background_threshold': backgroundThreshold,
    };
  }

  static const String _settingsKey = 'app_settings_json';

  static Future<void> save(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(settings.toJson());
      await prefs.setString(_settingsKey, jsonString);
    } catch (e) {
      debugPrint("Error saving settings: $e");
    }
  }

  static Future<AppSettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_settingsKey);
      if (jsonString != null) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return AppSettings.fromJson(jsonMap);
      }
    } catch (e) {
      debugPrint("Error loading/decoding settings: $e");
    }
    return AppSettings();
  }
}

/// Enum for background color types
enum BackgroundColorType {
  white,
  black,
  green,
}