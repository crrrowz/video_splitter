import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_splitter/models/app_settings.dart';
import 'package:video_splitter/models/app_config_loader.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final AppSettings settings;
  final AppConfig appConfig;

  const SettingsPage({Key? key, required this.settings, required this.appConfig}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _bitrateController;
  late TextEditingController _segmentTimeController;
  late TextEditingController _noiseThresholdController;
  late TextEditingController _silenceDurationController;
  late TextEditingController _backgroundDurationController;

  @override
  void initState() {
    super.initState();
    _bitrateController = TextEditingController(text: widget.settings.videoBitrate);
    _segmentTimeController = TextEditingController(text: widget.settings.segmentTime.toString());
    _noiseThresholdController = TextEditingController(text: widget.settings.noiseThreshold.toString());
    _silenceDurationController = TextEditingController(text: widget.settings.minSilenceDuration.toString());
    _backgroundDurationController = TextEditingController(text: widget.settings.backgroundMinDuration.toString());
  }

  @override
  void dispose() {
    _bitrateController.dispose();
    _segmentTimeController.dispose();
    _noiseThresholdController.dispose();
    _silenceDurationController.dispose();
    _backgroundDurationController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    widget.settings.videoBitrate = _bitrateController.text;
    widget.settings.segmentTime = int.tryParse(_segmentTimeController.text) ?? 60;
    widget.settings.noiseThreshold = double.tryParse(_noiseThresholdController.text) ?? -30.0;
    widget.settings.minSilenceDuration = double.tryParse(_silenceDurationController.text) ?? 0.5;
    widget.settings.backgroundMinDuration = double.tryParse(_backgroundDurationController.text) ?? 3.0;

    await AppSettings.save(widget.settings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveSettings();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'About',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.black87,
                    title: const Text('About', style: TextStyle(color: Colors.white)),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('App Name: ${widget.appConfig.appInfo.name}', style: const TextStyle(color: Colors.white)),
                          Text('Version: ${widget.appConfig.appInfo.version}', style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 16),
                          Text('Developer: ${widget.appConfig.developerInfo.name}', style: const TextStyle(color: Colors.white)),
                          Text('Company: ${widget.appConfig.developerInfo.company}', style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text('Email: ', style: TextStyle(color: Colors.white)),
                              GestureDetector(
                                onTap: () => launchUrl(Uri.parse('mailto:${widget.appConfig.developerInfo.email}')),
                                child: Text(widget.appConfig.developerInfo.email, style: const TextStyle(color: Colors.blue)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Website: ', style: TextStyle(color: Colors.white)),
                              GestureDetector(
                                onTap: () => launchUrl(Uri.parse(widget.appConfig.developerInfo.website)),
                                child: Text(widget.appConfig.developerInfo.website, style: const TextStyle(color: Colors.blue)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save Settings',
              onPressed: _saveSettings,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // === BASIC VIDEO SETTINGS ===
            Text('Basic Video Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            
            SwitchListTile(
              title: const Text('Enable Splitting'),
              subtitle: const Text('Split the video into multiple segments'),
              value: widget.settings.segmentTime > 0,
              onChanged: (bool value) {
                setState(() {
                  if (value) {
                    widget.settings.segmentTime = 60;
                    _segmentTimeController.text = '60';
                  } else {
                    widget.settings.segmentTime = 0;
                    _segmentTimeController.text = '0';
                  }
                });
              },
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _segmentTimeController,
                enabled: widget.settings.segmentTime > 0,
                decoration: const InputDecoration(
                  labelText: 'Segment Time (seconds)',
                  helperText: 'Duration of each output clip',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timelapse),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  widget.settings.segmentTime = int.tryParse(value) ?? 60;
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _bitrateController,
                decoration: const InputDecoration(
                  labelText: 'Video Bitrate',
                  helperText: "e.g., '4M' or '2000k'",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                ),
                onChanged: (value) {
                  widget.settings.videoBitrate = value;
                },
              ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Video Speed: ${widget.settings.speed.toStringAsFixed(1)}x', 
                         style: Theme.of(context).textTheme.titleMedium),
                    Slider(
                      value: widget.settings.speed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      label: '${widget.settings.speed.toStringAsFixed(1)}x',
                      onChanged: (value) {
                        setState(() {
                          widget.settings.speed = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Remove Audio'),
                    subtitle: const Text('Creates a video-only (mute) file'),
                    secondary: const Icon(Icons.volume_off),
                    value: widget.settings.removeAudio,
                    onChanged: (value) {
                      setState(() {
                        widget.settings.removeAudio = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Grayscale Filter'),
                    subtitle: const Text('Converts video to black and white'),
                    secondary: const Icon(Icons.filter_b_and_w),
                    value: widget.settings.grayscaleFilter,
                    onChanged: (value) {
                      setState(() {
                        widget.settings.grayscaleFilter = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Force H.264 Re-encode'),
                    subtitle: const Text('Standardize video to H.264 and copy audio'),
                    secondary: const Icon(Icons.transform),
                    value: widget.settings.forceH264,
                    onChanged: (value) {
                      setState(() {
                        widget.settings.forceH264 = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // === NOISE REMOVAL SETTINGS (conditionally rendered) ===
            if (widget.appConfig.features.noiseRemoval)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('Noise Removal Settings', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Enable Noise Removal'),
                          subtitle: const Text('Automatically remove noisy audio segments'),
                          secondary: const Icon(Icons.noise_control_off),
                          value: widget.settings.enableNoiseRemoval,
                          onChanged: (value) {
                            setState(() {
                              widget.settings.enableNoiseRemoval = value;
                            });
                          },
                        ),
                        if (widget.settings.enableNoiseRemoval) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _noiseThresholdController,
                                  decoration: const InputDecoration(
                                    labelText: 'Noise Threshold (dB)',
                                    helperText: 'Audio below this level is considered noise (e.g., -30)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.graphic_eq),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                  onChanged: (value) {
                                    widget.settings.noiseThreshold = double.tryParse(value) ?? -30.0;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _silenceDurationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Minimum Silence Duration (seconds)',
                                    helperText: 'Minimum duration to consider as removable noise',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.timer),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (value) {
                                    widget.settings.minSilenceDuration = double.tryParse(value) ?? 0.5;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            const Divider(),

            // === BACKGROUND REMOVAL SETTINGS (conditionally rendered) ===
            if (widget.appConfig.features.backgroundRemoval)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('Background Removal Settings', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Enable Background Removal'),
                          subtitle: const Text('Remove segments with solid color backgrounds'),
                          secondary: const Icon(Icons.blur_on),
                          value: widget.settings.enableBackgroundRemoval,
                          onChanged: (value) {
                            setState(() {
                              widget.settings.enableBackgroundRemoval = value;
                            });
                          },
                        ),
                        if (widget.settings.enableBackgroundRemoval) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Background Color', style: Theme.of(context).textTheme.titleSmall),
                                const SizedBox(height: 8),
                                SegmentedButton<BackgroundColorType>(
                                  segments: const [
                                    ButtonSegment(value: BackgroundColorType.white, label: Text('White'), icon: Icon(Icons.wb_sunny)),
                                    ButtonSegment(value: BackgroundColorType.black, label: Text('Black'), icon: Icon(Icons.brightness_2)),
                                    ButtonSegment(value: BackgroundColorType.green, label: Text('Green'), icon: Icon(Icons.nature)),
                                  ],
                                  selected: {widget.settings.backgroundColor},
                                  onSelectionChanged: (Set<BackgroundColorType> selected) {
                                    setState(() {
                                      widget.settings.backgroundColor = selected.first;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _backgroundDurationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Minimum Duration (seconds)',
                                    helperText: 'Minimum duration of background to remove (e.g., 3)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.timer),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (value) {
                                    widget.settings.backgroundMinDuration = double.tryParse(value) ?? 3.0;
                                  },
                                ),
                                const SizedBox(height: 16),
                                Text('Detection Threshold: ${(widget.settings.backgroundThreshold * 100).toInt()}%',
                                     style: Theme.of(context).textTheme.titleSmall),
                                Slider(
                                  value: widget.settings.backgroundThreshold,
                                  min: 0.8,
                                  max: 1.0,
                                  divisions: 20,
                                  label: '${(widget.settings.backgroundThreshold * 100).toInt()}%',
                                  onChanged: (value) {
                                    setState(() {
                                      widget.settings.backgroundThreshold = value;
                                    });
                                  },
                                ),
                                Text('Higher values = more strict detection',
                                     style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}