// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/features/short_videos/data/model/video_model.dart';
import 'package:list_in/features/short_videos/presentation/bloc/video_event.dart';
import 'package:list_in/features/short_videos/presentation/bloc/video_states.dart';
import 'package:video_player/video_player.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  static const int preloadCount = 2;
  static const int pageSize = 5;
  final Map<int, VideoPlayerController> _controllers = {};
  List<VideoModel> _videos = [];
  bool _isLoadingMore = false;
  int _currentPage = 0;
  int _currentVideoIndex = -1;
  Timer? _preloadTimer;
  bool _isDisposed = false;

  VideoBloc() : super(VideoInitial()) {
    on<InitializeVideos>(_onInitializeVideos);
    on<LoadMoreVideos>(_onLoadMoreVideos);
    on<PlayVideo>(_onPlayVideo);
    on<PauseVideo>(_onPauseVideo);
    on<DisposeVideos>(_onDisposeVideos);
  }

  Future<void> _onInitializeVideos(
      InitializeVideos event, Emitter<VideoState> emit) async {
    try {
      emit(VideosLoading());

      // Load first batch of videos
      final newVideos = await _fetchVideosFromApi(_currentPage);
      _videos = newVideos;

      // Initialize only the first video immediately
      await _initializeVideo(0);

      emit(VideosLoaded(_videos, _controllers));

      // Preload next videos in background
      _schedulePreload(1);
    } catch (e) {
      emit(VideoError('Failed to initialize videos: $e'));
    }
  }

  void _schedulePreload(int startIndex) {
    _preloadTimer?.cancel();
    _preloadTimer = Timer(const Duration(milliseconds: 100), () {
      if (!_isDisposed) {
        _preloadVideosInBackground(startIndex, preloadCount);
      }
    });
  }

 Future<void> _initializeVideo(int index) async {
    if (index >= _videos.length || _controllers.containsKey(index)) return;

    try {
      final controller = VideoPlayerController.network(
        _videos[index].url,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      
      await controller.initialize();
      controller.setLooping(true);
      await controller.seekTo(Duration.zero);
      await controller.setVolume(1.0);
      
      if (!_isDisposed) {
        _controllers[index] = controller;
        _videos[index].isPreloaded = true;
      } else {
        await controller.dispose();
      }
    } catch (e) {
      print('Failed to initialize video $index: $e');
      _videos[index].isPreloaded = false;
    }
  }


  Future<void> _onLoadMoreVideos(LoadMoreVideos event, Emitter<VideoState> emit) async {
    if (_isLoadingMore) return;
    
    try {
      _isLoadingMore = true;
      emit(VideosLoaded(_videos, _controllers, isLoadingMore: true));

      _currentPage++;
      final newVideos = await _fetchVideosFromApi(_currentPage);
      
      if (_isDisposed) return;
      
      _videos.addAll(newVideos);
      emit(VideosLoaded(_videos, _controllers));

      // Preload next video in background
      final nextIndex = _videos.length - newVideos.length;
      _schedulePreload(nextIndex);

    } catch (e) {
      if (!_isDisposed) {
        emit(VideoError('Failed to load more videos: $e'));
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> _preloadVideosInBackground(int startIndex, int count) async {
    for (var i = startIndex; i < min(startIndex + count, _videos.length); i++) {
      if (_isDisposed) return;
      if (!_controllers.containsKey(i) && !_videos[i].isPreloaded) {
        await _initializeVideo(i);
        if (!_isDisposed) {
          emit(VideosLoaded(_videos, _controllers));
        }
      }
    }
  }

   void _cleanupOldControllers(int currentIndex) async {
    final keysToRemove = <int>[];
    
    _controllers.forEach((index, controller) {
      if ((index < currentIndex - 1) || (index > currentIndex + 1)) {
        controller.dispose();
        keysToRemove.add(index);
        _videos[index].isPreloaded = false;
      }
    });

    for (var key in keysToRemove) {
      _controllers.remove(key);
    }
  }

  Future<void> _preloadVideos(int startIndex, int count) async {
    final futures = <Future>[];

    for (var i = startIndex; i < min(startIndex + count, _videos.length); i++) {
      if (!_controllers.containsKey(i) && !_videos[i].isPreloaded) {
        futures.add(_preloadSingleVideo(i));
      }
    }

    await Future.wait(futures);
  }

  Future<void> _preloadSingleVideo(int index) async {
    try {
      final controller = VideoPlayerController.network(
        _videos[index].url,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await controller.initialize();
      controller.setLooping(true);
      await controller.seekTo(Duration.zero);
      await controller.setVolume(1.0);

      _controllers[index] = controller;
      _videos[index].isPreloaded = true;
    } catch (e) {
      print('Failed to preload video $index: $e');
    }
  }

 

   Future<void> _onPlayVideo(PlayVideo event, Emitter<VideoState> emit) async {
    if (_isDisposed || event.index >= _videos.length) return;

    try {
      // First pause any currently playing video
      if (_currentVideoIndex != -1 && _currentVideoIndex != event.index) {
        final currentController = _controllers[_currentVideoIndex];
        if (currentController != null) {
          await currentController.pause();
          _videos[_currentVideoIndex].isPlaying = false;
        }
      }

      _currentVideoIndex = event.index;

      // Initialize the video if not already initialized
      if (!_controllers.containsKey(event.index)) {
        await _initializeVideo(event.index);
      }

      final controller = _controllers[event.index];
      if (controller != null && !_isDisposed) {
        await controller.seekTo(Duration.zero);
        await controller.setVolume(1.0);
        await controller.play();
        
        _videos[event.index].isPlaying = true;

        // Cleanup old controllers
        _cleanupOldControllers(event.index);

        // Schedule preload of next videos
        _schedulePreload(event.index + 1);

        emit(VideosLoaded(_videos, _controllers));
      }
    } catch (e) {
      if (!_isDisposed) {
        emit(VideoError('Failed to play video: $e'));
      }
    }
  }

  // Real video sources
  List<Map<String, String>> _getVideoSources() {
    return [
      {
        'url':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'thumbnail':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
        'title': 'Big Buck Bunny',
        'description': 'Big Buck Bunny tells the story of a giant rabbit'
      },
      {
        'url':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'thumbnail':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
        'title': 'Elephant Dream',
        'description': 'The first Blender Open Movie from 2006'
      },
      {
        'url':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'thumbnail':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
        'title': 'For Bigger Blazes',
        'description': 'HBO GO now works with Chromecast'
      },
      {
        'url':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'thumbnail':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
        'title': 'For Bigger Escape',
        'description':
            'Introducing Chromecast. The easiest way to enjoy online video and music on your TV.'
      },
      {
        'url':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'thumbnail':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg',
        'title': 'For Bigger Fun',
        'description':
            'Introducing Chromecast. The easiest way to enjoy online video and music on your TV.'
      },
      {
        'url':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        'thumbnail':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg',
        'title': 'For Bigger Joyrides',
        'description':
            'Introducing Chromecast. The easiest way to enjoy online video and music on your TV.'
      },
      {
        'url':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
        'thumbnail':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg',
        'title': 'For Bigger Meltdowns',
        'description':
            'Introducing Chromecast. The easiest way to enjoy online video and music on your TV.'
      },
      {
        'url':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        'thumbnail':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg',
        'title': 'Sintel',
        'description': 'Third Blender Open Movie from 2010'
      },
      {
        'url':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
        'thumbnail':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg',
        'title': 'Subaru Outback On Street And Dirt',
        'description':
            'Smoking Tire takes the all-new Subaru Outback to the highest point we can find.'
      },
      {
        'url':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
        'thumbnail':
            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg',
        'title': 'Tears of Steel',
        'description':
            'Tears of Steel was realized with crowd-funding by users of the open source 3D creation tool Blender.'
      },
      // Add more video sources as needed
    ];
  }

  Future<List<VideoModel>> _fetchVideosFromApi(int page) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final allVideos = _getVideoSources();
    final startIndex = (page * pageSize) % allVideos.length;
    final endIndex = min(startIndex + pageSize, allVideos.length);

    // Cycle through videos if we reach the end
    List<Map<String, String>> pageVideos;
    if (endIndex > startIndex) {
      pageVideos = allVideos.sublist(startIndex, endIndex);
    } else {
      pageVideos = [
        ...allVideos.sublist(startIndex),
        ...allVideos.sublist(0, pageSize - (allVideos.length - startIndex))
      ];
    }

    return pageVideos
        .map((videoData) => VideoModel(
              url: videoData['url']!,
              thumbnail: videoData['thumbnail']!,
              title: videoData['title']!,
              description: videoData['description']!,
            ))
        .toList();
  }

  Future<void> _onPreloadNextVideos(
      PreloadNextVideos event, Emitter<VideoState> emit) async {
    if (_currentVideoIndex != -1) {
      final nextIndex = _currentVideoIndex + 1;
      if (nextIndex < _videos.length) {
        await _preloadVideos(nextIndex, preloadCount);
        emit(VideosLoaded(_videos, _controllers));
      }
    }
  }

  Future<void> _onPauseVideo(PauseVideo event, Emitter<VideoState> emit) async {
    if (_isDisposed) return;

    try {
      final controller = _controllers[event.index];
      if (controller != null) {
        await controller.pause();
        _videos[event.index].isPlaying = false;
        emit(VideosLoaded(_videos, _controllers));
      }
    } catch (e) {
      if (!_isDisposed) {
        emit(VideoError('Failed to pause video: $e'));
      }
    }
  }
    Future<void> _onDisposeVideos(DisposeVideos event, Emitter<VideoState> emit) async {
    _isDisposed = true;
    _preloadTimer?.cancel();
    
    for (var controller in _controllers.values) {
      await controller.pause();
      await controller.dispose();
    }
    _controllers.clear();
    
    emit(VideoInitial());
  }


   @override
  Future<void> close() async {
    _isDisposed = true;
    _preloadTimer?.cancel();
    
    for (var controller in _controllers.values) {
      await controller.pause();
      await controller.dispose();
    }
    _controllers.clear();
    
    return super.close();
  }
}
