// ignore_for_file: avoid_print

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/post/domain/repository/post_repository.dart';
import 'package:list_in/features/video/service/video_compresion_service.dart';

class UploadVideoUseCase implements UseCase2<String, XFile> {
  final PostRepository repository;
  final VideoCompressionService compressionService;
  final VideoQuality compressionQuality;

  UploadVideoUseCase(this.repository, this.compressionService,
      {this.compressionQuality =
          VideoQuality.medium} // Default to medium quality
      );
  Future<Either<Failure, String>> call({XFile? params}) async {
    if (params == null) {
      return Left(ServerFailure());
    }

    print('😌😌😌Starting video processing...');

    // Compress the video first
    final compressionResult = await compressionService.compressVideo(
      params,
      quality: VideoQuality.low,
    );

    return compressionResult.fold(
      (failure) {
        print('😌😌😌Compression failed');
        return Left(failure);
      },
      (compResult) async {
        // Log compression result
        print('😌😌😌Video compressed successfully:');
        print('😌😌😌Original size: ${compResult.originalSizeFormatted}');
        print('😌😌😌Compressed size: ${compResult.compressedSizeFormatted}');
        print('😌😌😌Space saved: ${compResult.compressionRatioFormatted}');

        // Create a new XFile from the compressed video path
        final compressedVideo = XFile(compResult.path);

        // Try to optimize for fast start
        try {
          final optimizationResult = await compressionService
              .optimizeVideoForFastStart(compResult.path);

          return optimizationResult.fold(
            (failure) {
              print(
                  '😌😌😌Fast start optimization failed, uploading compressed video');
              return uploadVideo(compressedVideo);
            },
            (optimizedPath) {
              print('😌😌😌Fast start optimization successful');
              final optimizedVideo = XFile(optimizedPath);
              return uploadVideo(optimizedVideo);
            },
          );
        } catch (e) {
          print(
              '😌😌😌Fast start optimization error: $e, uploading compressed video');
          return uploadVideo(compressedVideo);
        }
      },
    );
  }

  // Helper method to upload video
  Future<Either<Failure, String>> uploadVideo(XFile video) async {
    print('😌😌😌Uploading video...');
    final uploadResult = await repository.uploadVideo(video);
    return uploadResult.fold(
      (failure) {
        print('😌😌😌Upload failed');
        return Left(failure);
      },
      (uploadUrl) {
        print('😌😌😌Video uploaded successfully to: $uploadUrl');
        return Right(uploadUrl);
      },
    );
  }
}
