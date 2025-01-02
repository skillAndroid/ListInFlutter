import 'package:list_in/features/short_videos/data/model/video_model.dart';
import 'package:video_player/video_player.dart';

abstract class VideoState {}

class VideoInitial extends VideoState {}
class VideosLoading extends VideoState {}
class VideosLoaded extends VideoState {
  final List<VideoModel> videos;
  final Map<int, VideoPlayerController> controllers;
  final bool isLoadingMore;

  VideosLoaded(this.videos, this.controllers, {this.isLoadingMore = false});
}
class VideoError extends VideoState {
  final String message;
  VideoError(this.message);
}
