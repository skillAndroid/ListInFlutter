abstract class VideoEvent {}

class InitializeVideos extends VideoEvent {}
class PreloadNextVideos extends VideoEvent {}
class LoadMoreVideos extends VideoEvent {}
class DisposeVideos extends VideoEvent {}
class PlayVideo extends VideoEvent {
  final int index;
  PlayVideo(this.index);
}
class PauseVideo extends VideoEvent {
  final int index;
  PauseVideo(this.index);
}