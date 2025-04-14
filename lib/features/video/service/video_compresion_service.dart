// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:io';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:image_picker/image_picker.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:path/path.dart' as path;
import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';

class CompressionResult {
  final String path;
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;

  CompressionResult({
    required this.path,
    required this.originalSize,
    required this.compressedSize,
  }) : compressionRatio = originalSize > 0
            ? (originalSize - compressedSize) / originalSize * 100
            : 0;

  String get originalSizeFormatted => _formatFileSize(originalSize);
  String get compressedSizeFormatted => _formatFileSize(compressedSize);
  String get compressionRatioFormatted =>
      '${compressionRatio.toStringAsFixed(1)}%';

  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  @override
  String toString() {
    return '😌😌😌Video compression: $originalSizeFormatted → $compressedSizeFormatted (saved $compressionRatioFormatted)';
  }
}

class VideoCompressionService {
  final LightCompressor _lightCompressor = LightCompressor();

  Stream<double> get compressionProgress => _lightCompressor.onProgressUpdated;

  /// Compresses a video file using the standard VideoQuality level from the package
  /// Returns Either a Failure or a CompressionResult with file sizes
  Future<Either<Failure, CompressionResult>> compressVideo(XFile videoFile,
      {VideoQuality quality = VideoQuality.medium}) async {
    try {
      // Get original file size
      final File originalFile = File(videoFile.path);
      final int originalSize = await originalFile.length();

      // Log the original file size
      print('😌😌😌Original video size: ${_formatFileSize(originalSize)}');
      print(
          '😌😌😌Starting compression with quality: ${quality.toString().split('.').last}...');

      // Get temporary directory to save compressed video

      // Extract file name from original path
      final String videoName =
          '${path.basenameWithoutExtension(videoFile.path)}_compressed.mp4';

      // Perform compression using the VideoQuality level from the package
      final Result response = await _lightCompressor.compressVideo(
        path: videoFile.path,
        videoQuality: VideoQuality.low,
        // Use the provided quality level from the package
        isMinBitrateCheckEnabled: false, // Allow compression for all videos
        video: Video(
          videoName: videoName,
          keepOriginalResolution: true, // Keep original resolution
        ),
        android: AndroidConfig(
          isSharedStorage: true, // Use app-specific storage
          saveAt: SaveAt.Movies,
        ),
        ios: IOSConfig(
          saveInGallery: false, // Don't save in gallery, just return the path
        ),
        disableAudio: false, // Keep audio
      );

      // Handle compression result
      if (response is OnSuccess) {
        // Get compressed file size
        final File compressedFile = File(response.destinationPath);
        final int compressedSize = await compressedFile.length();

        // Create compression result
        final compressionResult = CompressionResult(
          path: response.destinationPath,
          originalSize: originalSize,
          compressedSize: compressedSize,
        );

        // Log the compressed file size and ratio
        print(
            '😌😌😌Compressed video size: ${_formatFileSize(compressedSize)}');
        print(
            '😌😌😌Space saved: ${compressionResult.compressionRatioFormatted}');

        return Right(compressionResult);
      } else if (response is OnFailure) {
        print('😌😌😌Video compression failed: ${response.message}');
        return Left(ServerFailure());
      } else if (response is OnCancelled) {
        print('😌😌😌Video compression was cancelled');
        return Left(ServerFailure());
      } else {
        print('😌😌😌Unknown compression error');
        return Left(ServerFailure());
      }
    } catch (e) {
      print('😌😌😌Error during video compression: $e');
      return Left(ServerFailure());
    }
  }

  /// Cancels ongoing compression
  void cancelCompression() {
    _lightCompressor.cancelCompression();
    print('😌😌😌Compression cancelled');
  }

// Add this method to your VideoCompressionService class
  Future<Either<Failure, String>> optimizeVideoForFastStart(
      String videoPath) async {
    try {
      // Create a new output path for the optimized video
      final String directory = path.dirname(videoPath);
      final String filename = path.basenameWithoutExtension(videoPath);
      final String outputPath =
          path.join(directory, '${filename}_faststart.mp4');

      print('😌😌😌Optimizing video for fast start...');

      // Execute FFmpeg command to move moov atom to the beginning
      final session = await FFmpegKit.execute(
          '-i "$videoPath" -movflags faststart -c copy "$outputPath"');

      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print('😌😌😌Fast start optimization completed successfully');

        // Delete the original compressed file to save space (optional)
        await File(videoPath).delete();

        return Right(outputPath);
      } else {
        print(
            '😌😌😌Fast start optimization failed with return code: $returnCode');
        return Left(ServerFailure());
      }
    } catch (e) {
      print('😌😌😌Error during fast start optimization: $e');
      return Left(ServerFailure());
    }
  }

  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
