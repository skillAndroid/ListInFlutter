import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/post/domain/repository/post_repository.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';

class UploadImagesUseCase implements UseCase2<List<String>, List<XFile>> {
  final PostRepository repository;

  static const int maxFileSize = 125 * 1024;
  static const int minQuality = 1;
  static const int maxQuality = 100;
  static const double aspectRatio = 1.5;

  UploadImagesUseCase(this.repository);

  void _logDebug(String message) {
    if (kDebugMode) {
      print('🔍 [ImageUpload] $message');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Future<Either<Failure, List<String>>> call({List<XFile>? params}) async {
    if (params == null) {
      _logDebug('❌ No images provided');
      return Left(ServerFailure());
    }

    try {
      _logDebug('📸 Starting compression for ${params.length} images');

      List<XFile> compressedImages =
          await Future.wait(params.map((file) => compressImage(file)));

      _logDebug('✅ Compression completed for all images');
      return await repository.uploadImages(compressedImages);
    } catch (e) {
      _logDebug('❌ Error during compression: $e');
      return Left(ServerFailure());
    }
  }

  Future<(int, int)> _calculateDimensions(
      int originalWidth, int originalHeight) {
    double ratio = originalWidth / originalHeight;
    int targetWidth, targetHeight;

    if (ratio > aspectRatio) {
      targetWidth = 1080;
      targetHeight = (1080 / ratio).round();
    } else {
      targetHeight = 720;
      targetWidth = (720 * ratio).round();
    }

    return Future.value((targetWidth, targetHeight));
  }

  Future<Uint8List?> _compressWithQuality(
      XFile file, int quality, CompressFormat format) async {
    final imageBytes = await file.readAsBytes();
    final decodedImage = await decodeImageFromList(imageBytes);
    final (targetWidth, targetHeight) =
        await _calculateDimensions(decodedImage.width, decodedImage.height);

    return await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: targetWidth,
      minHeight: targetHeight,
      quality: quality,
      rotate: 0,
      format: format,
      autoCorrectionAngle: true,
      keepExif: false,
    );
  }

  Future<XFile> compressImage(XFile file) async {
    _logDebug('🔄 Starting compression for: ${file.path}');

    final Directory tempDir = await getTemporaryDirectory();
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path_lib.basename(file.path)}';
    final String targetPath = path_lib.join(tempDir.path, fileName);

    final File imageFile = File(file.path);
    final int originalSize = await imageFile.length();

    if (originalSize <= maxFileSize) {
      _logDebug(
          '⏩ File already under target size: ${_formatFileSize(originalSize)}');
      return file;
    }

    _logDebug('📊 Original size: ${_formatFileSize(originalSize)}');
    final Stopwatch stopwatch = Stopwatch()..start();

    // Always use JPEG for consistent compression
    CompressFormat format = CompressFormat.jpeg;

    // Binary search for the optimal quality setting
    int low = minQuality;
    int high = maxQuality;
    int bestQuality = low;
    Uint8List? bestResult;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      _logDebug('🔄 Trying quality: $mid');

      final result = await _compressWithQuality(file, mid, format);

      if (result == null) {
        _logDebug('❌ Compression failed at quality: $mid');
        high = mid - 1;
        continue;
      }

      if (result.length <= maxFileSize) {
        bestResult = result;
        bestQuality = mid;
        low = mid + 1; // Try higher quality
      } else {
        high = mid - 1; // Try lower quality
      }
    }

    if (bestResult == null) {
      _logDebug('❌ Could not achieve target size, using minimum quality');
      bestResult = await _compressWithQuality(file, minQuality, format);

      if (bestResult == null) {
        _logDebug('❌ Compression failed completely');
        return file;
      }
    }

    await File(targetPath).writeAsBytes(bestResult);
    final int compressedSize = await File(targetPath).length();
    stopwatch.stop();

    final double compressionRatio = originalSize / compressedSize;
    final double savingsPercentage =
        ((originalSize - compressedSize) / originalSize * 100);

    _logDebug('''
📊 Compression Results:
   • Original size: ${_formatFileSize(originalSize)}
   • Compressed size: ${_formatFileSize(compressedSize)}
   • Final quality: $bestQuality
   • Compression ratio: ${compressionRatio.toStringAsFixed(2)}x
   • Space saved: ${savingsPercentage.toStringAsFixed(2)}%
   • Processing time: ${stopwatch.elapsedMilliseconds}ms
    ''');

    return XFile(targetPath);
  }
}
