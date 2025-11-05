package com.example.video_splitter

import android.content.ContentValues
import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant // <-- 1. ADD THIS IMPORT
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.video_splitter/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // --- 2. ADD THIS LINE ---
        // This line registers all your plugins (permission_handler, image_picker, etc.)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        // --- END OF ADDITION ---

        // This is your custom channel for the media scanner
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanFile" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        scanFile(path)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Path cannot be null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun scanFile(path: String) {
        val file = File(path)
        if (!file.exists()) {
            println("File does not exist: $path")
            return
        }

        try {
            // Method 1: MediaScannerConnection
            MediaScannerConnection.scanFile(
                this,
                arrayOf(file.absolutePath),
                arrayOf("video/mp4")
            ) { scannedPath, uri ->
                println("✅ MediaScanner finished: $scannedPath")
                println("✅ URI: $uri")
            }

            // Method 2: Broadcast Intent (more reliable for older Android versions)
            val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
            mediaScanIntent.data = Uri.fromFile(file)
            sendBroadcast(mediaScanIntent)
            println("✅ Broadcast sent for: ${file.absolutePath}")

            // Method 3: Insert into MediaStore (most reliable for Android 10+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                insertVideoToMediaStore(file)
            }

        } catch (e: Exception) {
            println("❌ Error scanning file: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun insertVideoToMediaStore(file: File) {
        try {
            val values = ContentValues().apply {
                put(MediaStore.Video.Media.DISPLAY_NAME, file.name)
                put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
                put(MediaStore.Video.Media.DATA, file.absolutePath)
                put(MediaStore.Video.Media.IS_PENDING, 0)
            }

            val uri = contentResolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)
            if (uri != null) {
                println("✅ Video inserted to MediaStore: $uri")
            } else {
                println("❌ Failed to insert video to MediaStore")
            }
        } catch (e: Exception) {
            println("❌ Error inserting to MediaStore: ${e.message}")
            e.printStackTrace()
        }
    }
}