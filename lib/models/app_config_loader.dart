import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:yaml/yaml.dart';

/// App configuration loaded from JSON file
class AppConfig {
  final AppInfo appInfo;
  final DeveloperInfo developerInfo;
  final AppSettingsDefaults appSettings;
  final Features features;
  final Privacy privacy;

  AppConfig({
    required this.appInfo,
    required this.developerInfo,
    required this.appSettings,
    required this.features,
    required this.privacy,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json, YamlMap pubspec) {
    return AppConfig(
      appInfo: AppInfo.from(json['app_info'] ?? {}, pubspec),
      developerInfo: DeveloperInfo.fromJson(json['developer_info'] ?? {}),
      appSettings: AppSettingsDefaults.fromJson(json['app_settings'] ?? {}),
      features: Features.fromJson(json['features'] ?? {}),
      privacy: Privacy.fromJson(json['privacy'] ?? {}),
    );
  }

  /// Load configuration from assets
  static Future<AppConfig> load() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/config/app_config.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final String pubspecString = await rootBundle.loadString('pubspec.yaml');
      final YamlMap pubspecMap = loadYaml(pubspecString);
      return AppConfig.fromJson(jsonMap, pubspecMap);
    } catch (e) {
      debugPrint('Error loading app config: $e');
      // Return default config if loading fails
      final String pubspecString = await rootBundle.loadString('pubspec.yaml');
      final YamlMap pubspecMap = loadYaml(pubspecString);
      return AppConfig(
        appInfo: AppInfo.from({}, pubspecMap),
        developerInfo: DeveloperInfo(
          name: 'Hassanein Hassan AlKhafaji',
          email: 'admin@innovacode.org',
          website: 'https://innovacode.org/crowz',
          company: 'innovacode',
        ),
        appSettings: AppSettingsDefaults(
          defaultSegmentTime: 60,
          defaultSpeed: 1.0,
          defaultVideoBitrate: '4M',
          outputDirectory: 'video_splitter',
        ),
        features: Features(
          videoSplitting: true,
          speedAdjustment: true,
          grayscaleFilter: true,
          audioRemoval: true,
          hardwareAcceleration: true,
        ),
        privacy: Privacy(
          collectsData: false,
          sharesData: false,
          storesLocallyOnly: true,
        ),
      );
    }
  }
}

class AppInfo {
  final String name;
  final String packageName;
  final String version;
  final int buildNumber;
  final String description;

  AppInfo({
    required this.name,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.description,
  });

  factory AppInfo.from(Map<String, dynamic> json, YamlMap pubspec) {
    final versionString = pubspec['version'] ?? '1.0.0+1';
    final versionParts = versionString.split('+');
    return AppInfo(
      name: json['name'] ?? pubspec['name'] ?? 'Video Splitter',
      packageName: pubspec['name'] ?? 'com.videosplitter.app',
      version: versionParts[0],
      buildNumber: int.tryParse(versionParts.length > 1 ? versionParts[1] : '1') ?? 1,
      description: pubspec['description'] ?? '',
    );
  }
}

class DeveloperInfo {
  final String name;
  final String email;
  final String website;
  final String company;

  DeveloperInfo({
    required this.name,
    required this.email,
    required this.website,
    required this.company,
  });

  factory DeveloperInfo.fromJson(Map<String, dynamic> json) {
    return DeveloperInfo(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      company: json['company'] ?? '',
    );
  }
}

class AppSettingsDefaults {
  final int defaultSegmentTime;
  final double defaultSpeed;
  final String defaultVideoBitrate;
  final String outputDirectory;

  AppSettingsDefaults({
    required this.defaultSegmentTime,
    required this.defaultSpeed,
    required this.defaultVideoBitrate,
    required this.outputDirectory,
  });

  factory AppSettingsDefaults.fromJson(Map<String, dynamic> json) {
    return AppSettingsDefaults(
      defaultSegmentTime: json['default_segment_time'] ?? 60,
      defaultSpeed: (json['default_speed'] ?? 1.0).toDouble(),
      defaultVideoBitrate: json['default_video_bitrate'] ?? '4M',
      outputDirectory: json['output_directory'] ?? 'video_splitter',
    );
  }
}

class Features {
  final bool videoSplitting;
  final bool speedAdjustment;
  final bool grayscaleFilter;
  final bool audioRemoval;
  final bool hardwareAcceleration;
  final bool backgroundRemoval;

  Features({
    required this.videoSplitting,
    required this.speedAdjustment,
    required this.grayscaleFilter,
    required this.audioRemoval,
    required this.hardwareAcceleration,
    required this.backgroundRemoval,
  });

  factory Features.fromJson(Map<String, dynamic> json) {
    return Features(
      videoSplitting: json['video_splitting'] ?? true,
      speedAdjustment: json['speed_adjustment'] ?? true,
      grayscaleFilter: json['grayscale_filter'] ?? true,
      audioRemoval: json['audio_removal'] ?? true,
      hardwareAcceleration: json['hardware_acceleration'] ?? true,
      backgroundRemoval: json['background_removal'] ?? false,
    );
  }
}

class Privacy {
  final bool collectsData;
  final bool sharesData;
  final bool storesLocallyOnly;

  Privacy({
    required this.collectsData,
    required this.sharesData,
    required this.storesLocallyOnly,
  });

  factory Privacy.fromJson(Map<String, dynamic> json) {
    return Privacy(
      collectsData: json['collects_data'] ?? false,
      sharesData: json['shares_data'] ?? false,
      storesLocallyOnly: json['stores_locally_only'] ?? true,
    );
  }
}