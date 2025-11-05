# Flutter's default rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# --- permission_handler ---
-keep class com.baseflow.permissionhandler.** { *; }

# --- ffmpeg_kit_flutter_new (Corrected Rule) ---
-keep class com.antonkarpenko.ffmpegkit.** { *; }

# --- shared_preferences (Pigeon-based) ---
-keep class dev.flutter.pigeon.shared_preferences_android.** { *; }

# --- image_picker (Pigeon-based) ---
-keep class dev.flutter.pigeon.image_picker_android.** { *; }

# --- path_provider (Pigeon-based) ---
-keep class dev.flutter.pigeon.path_provider_android.** { *; }

# --- Google Play Core (for Flutter deferred components) ---
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }