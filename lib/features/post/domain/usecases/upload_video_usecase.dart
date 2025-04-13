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

  @override
  Future<Either<Failure, String>> call({XFile? params}) async {
    if (params == null) {
      return Left(ServerFailure());
    }

    print('😌😌😌Starting video compression...');

    // Compress the video before uploading using the package's quality levels
    final compressionResult = await compressionService.compressVideo(params,
        quality: compressionQuality);

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

        print('😌😌😌Uploading compressed video...');

        // Upload the compressed video
        final uploadResult = await repository.uploadVideo(compressedVideo);

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
      },
    );
  }
}
