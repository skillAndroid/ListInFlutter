import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/features/video/bloc/state.dart';

class VideoCubit extends Cubit<VideoState> {
  VideoCubit() : super(const VideoState());
  
  void updateVisibility(String id, double visibility) {
    final newVisibility = Map<String, double>.from(state.visibility);
    newVisibility[id] = visibility;
    
    String? mostVisibleId;
    double maxVisibility = 0.0;
    
    newVisibility.forEach((id, vis) {
      if (vis > maxVisibility && vis > 0.7) {
        maxVisibility = vis;
        mostVisibleId = id;
      }
    });
    
    emit(state.copyWith(
      visibility: newVisibility,
      currentlyPlayingId: mostVisibleId,
    ));
  }
  
  void initializeVideo(String id) {
    final newInitialized = Map<String, bool>.from(state.isInitialized);
    newInitialized[id] = true;
    emit(state.copyWith(isInitialized: newInitialized));
  }
}