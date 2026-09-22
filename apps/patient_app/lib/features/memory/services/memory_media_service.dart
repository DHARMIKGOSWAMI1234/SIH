import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/memory_categories.dart';
import '../../../core/theme/smriti_theme.dart';

/// Manages local-first media storage and safe rendering for personal memories.
///
/// Ensures photos and voice recordings remain strictly on-device,
/// never uploaded to external AI services, and handles missing or
/// deleted files gracefully without losing metadata.
class MemoryMediaService {
  static const String _mediaSubdir = 'smriti_memories_media';

  /// Returns the directory path for local memory media storage.
  static Future<Directory> getMediaStorageDirectory() async {
    if (kIsWeb) {
      return Directory('/web_storage');
    }
    final docDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(docDir.path, _mediaSubdir));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir;
  }

  /// Copies an external photo file into the local app storage.
  /// Returns the new local file path.
  static Future<String?> copyPhotoToLocalStorage(String sourcePath) async {
    if (kIsWeb) return sourcePath;
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      final targetDir = await getMediaStorageDirectory();
      final ext = p.extension(sourcePath);
      final filename = 'photo_${DateTime.now().millisecondsSinceEpoch}_${sourceFile.hashCode}$ext';
      final targetFile = File(p.join(targetDir.path, filename));

      await sourceFile.copy(targetFile.path);
      return targetFile.path;
    } catch (e) {
      debugPrint('[MemoryMediaService] Error copying photo: $e');
      return null;
    }
  }

  /// Safely checks whether a media file exists on disk.
  static bool isMediaAvailable(String? filePath) {
    if (filePath == null || filePath.trim().isEmpty) return false;
    if (kIsWeb) return true; // On web, treat non-empty as asset or blob
    try {
      return File(filePath).existsSync();
    } catch (_) {
      return false;
    }
  }

  /// Safely deletes a local media file if present.
  static Future<bool> deleteLocalMedia(String? filePath) async {
    if (filePath == null || filePath.trim().isEmpty || kIsWeb) return false;
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      debugPrint('[MemoryMediaService] Error deleting file: $e');
    }
    return false;
  }

  /// Builds a resilient thumbnail widget for a memory.
  ///
  /// Falls back gracefully to category icon if photo is absent,
  /// invalid, or deleted, ensuring zero red-screen crashes.
  static Widget buildThumbnail({
    required String? imagePath,
    required MemoryCategory category,
    double height = 140.0,
    double width = double.infinity,
    BorderRadius? borderRadius,
    bool isDark = false,
  }) {
    final radius = borderRadius ?? BorderRadius.circular(12.0);

    if (imagePath != null && imagePath.isNotEmpty && !kIsWeb) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: radius,
          child: Image.file(
            file,
            height: height,
            width: width,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallback(category, height, width, radius, isDark);
            },
          ),
        );
      }
    }

    return _buildFallback(category, height, width, radius, isDark);
  }

  static Widget _buildFallback(
    MemoryCategory category,
    double height,
    double width,
    BorderRadius radius,
    bool isDark,
  ) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: isDark ? SmritiTheme.darkSurfaceCard : category.color.withAlpha(25),
        borderRadius: radius,
        border: Border.all(
          color: isDark ? SmritiTheme.darkBorder : category.color.withAlpha(50),
          width: 1.0,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: 44.0,
              color: isDark ? SmritiTheme.sageAccentDark : category.color,
            ),
            const SizedBox(height: 6.0),
            Text(
              category.name.toUpperCase(),
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: isDark ? SmritiTheme.darkTextSecondary : category.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
