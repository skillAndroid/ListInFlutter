import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img_lib;
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/post/domain/repository/post_repository.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';

class UploadImagesUseCase implements UseCase2<List<String>, List<XFile>> {
  final PostRepository repository;
  
  // Constants for image processing
  static const int maxImageDimension = 1200;
  static const int jpegQuality = 85;
  static const int pngCompressionLevel = 9;
  
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
      
      List<XFile> compressedImages = await Future.wait(
        params.map((file) => compressImage(file))
      );
      
      _logDebug('✅ Compression completed for all images');
      return await repository.uploadImages(compressedImages);
    } catch (e) {
      _logDebug('❌ Error during compression: $e');
      return Left(ServerFailure());
    }
  }

  img_lib.Image _resizeIfNeeded(img_lib.Image image) {
    final int originalWidth = image.width;
    final int originalHeight = image.height;
    
    // If both dimensions are already smaller than max, return original
    if (originalWidth <= maxImageDimension && originalHeight <= maxImageDimension) {
      _logDebug('📏 Image already within size limits, skipping resize');
      return image;
    }

    // Calculate new dimensions maintaining aspect ratio
    double ratio = originalWidth / originalHeight;
    int newWidth, newHeight;

    if (originalWidth > originalHeight) {
      newWidth = maxImageDimension;
      newHeight = (maxImageDimension / ratio).round();
    } else {
      newHeight = maxImageDimension;
      newWidth = (maxImageDimension * ratio).round();
    }

    _logDebug('📏 Resizing from ${originalWidth}x${originalHeight} to ${newWidth}x${newHeight}');
    return img_lib.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img_lib.Interpolation.linear
    );
  }

  Future<XFile> compressImage(XFile file) async {
    _logDebug('🔄 Starting compression for: ${file.path}');
    
    final Directory tempDir = await getTemporaryDirectory();
    final String targetPath = path_lib.join(tempDir.path, 
      '${DateTime.now().millisecondsSinceEpoch}_${path_lib.basename(file.path)}');
    
    final File imageFile = File(file.path);
    final int originalSize = await imageFile.length();
    _logDebug('📊 Original file size: ${_formatFileSize(originalSize)}');
    
    final Stopwatch stopwatch = Stopwatch()..start();
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img_lib.Image? originalImage = img_lib.decodeImage(imageBytes);
    
    if (originalImage == null) {
      _logDebug('❌ Failed to decode image');
      throw Exception('Failed to decode image');
    }
    
    _logDebug('📐 Original dimensions: ${originalImage.width}x${originalImage.height}');
    
    // Resize image if needed
    final img_lib.Image processedImage = _resizeIfNeeded(originalImage);
    
    Uint8List compressedBytes;
    final String extension = path_lib.extension(file.path).toLowerCase();
    
    _logDebug('🎨 Processing image format: $extension');
    
    if (extension == '.png') {
      _logDebug('🔄 Using PNG compression...');
      compressedBytes = Uint8List.fromList(
        img_lib.encodePng(processedImage, level: pngCompressionLevel)
      );
      _logDebug('✅ PNG compression completed');
    } else {
      _logDebug('🔄 Using JPEG compression...');
      compressedBytes = Uint8List.fromList(
        img_lib.encodeJpg(processedImage, quality: jpegQuality)
      );
      _logDebug('✅ JPEG compression completed');
    }
    
    await File(targetPath).writeAsBytes(compressedBytes);
    final int compressedSize = await File(targetPath).length();
    stopwatch.stop();
    
    final double compressionRatio = originalSize / compressedSize;
    final double savingsPercentage = ((originalSize - compressedSize) / originalSize * 100);
    
    _logDebug('''
📊 Compression Results:
   • Original size: ${_formatFileSize(originalSize)}
   • Compressed size: ${_formatFileSize(compressedSize)}
   • Compression ratio: ${compressionRatio.toStringAsFixed(2)}x
   • Space saved: ${savingsPercentage.toStringAsFixed(2)}%
   • Processing time: ${stopwatch.elapsedMilliseconds}ms
    ''');
    
    return XFile(targetPath);
  }
}

extension ImageDebugExtension on XFile {
  Future<void> logImageInfo() async {
    if (kDebugMode) {
      final File file = File(path);
      final int size = await file.length();
      final Uint8List bytes = await file.readAsBytes();
      final img_lib.Image? image = img_lib.decodeImage(bytes);
      
      print('''
📸 Image Information:
   • Path: $path
   • Size: ${(size / 1024).toStringAsFixed(2)} KB
   • Dimensions: ${image?.width}x${image?.height}
   • Format: ${path.split('.').last.toUpperCase()}
      ''');
    }
  }
}