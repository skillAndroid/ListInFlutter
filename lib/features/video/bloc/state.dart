import 'package:equatable/equatable.dart';

class VideoState extends Equatable {
  final String? currentlyPlayingId;
  final Map<String, double> visibility;
  final Map<String, bool> isInitialized;

  const VideoState({
    this.currentlyPlayingId,
    this.visibility = const {},
    this.isInitialized = const {},
  });

  VideoState copyWith({
    String? currentlyPlayingId,
    Map<String, double>? visibility,
    Map<String, bool>? isInitialized,
  }) {
    return VideoState(
      currentlyPlayingId: currentlyPlayingId ?? this.currentlyPlayingId,
      visibility: visibility ?? this.visibility,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => throw UnimplementedError();
}
