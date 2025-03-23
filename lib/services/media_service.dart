import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class MediaService {
  final _imagePicker = ImagePicker();
  final _uuid = Uuid();

  Future<String> get _mediaDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir.path;
  }

  Future<String?> pickAndSaveImage({bool fromCamera = false}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return null;

      final String fileName = '${_uuid.v4()}${path.extension(pickedFile.path)}';
      final String savedPath = await _saveFile(pickedFile.path, fileName);

      return savedPath;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  Future<String?> pickAndSaveDocument() async {
    try {
      // Implement document picking logic
      // This would typically use a file picker package
      return null;
    } catch (e) {
      throw Exception('Failed to pick document: $e');
    }
  }

  Future<String> _saveFile(String sourcePath, String fileName) async {
    try {
      final mediaDir = await _mediaDirectory;
      final targetPath = '$mediaDir/$fileName';

      await File(sourcePath).copy(targetPath);
      return targetPath;
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<List<String>> getAttachments(List<String> attachmentPaths) async {
    try {
      final existingFiles = <String>[];

      for (final path in attachmentPaths) {
        final file = File(path);
        if (await file.exists()) {
          existingFiles.add(path);
        }
      }

      return existingFiles;
    } catch (e) {
      throw Exception('Failed to get attachments: $e');
    }
  }

  Future<void> cleanupOrphanedFiles(Set<String> usedPaths) async {
    try {
      final mediaDir = await _mediaDirectory;
      final directory = Directory(mediaDir);

      await for (final entity in directory.list()) {
        if (entity is File && !usedPaths.contains(entity.path)) {
          await entity.delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to cleanup files: $e');
    }
  }
}
