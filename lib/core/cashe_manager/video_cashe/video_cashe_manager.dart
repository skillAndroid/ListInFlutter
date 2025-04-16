import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoCacheManager {
  static final VideoCacheManager _instance = VideoCacheManager._internal();
  factory VideoCacheManager() => _instance;
  VideoCacheManager._internal();

  // Cache directory
  Directory? _cacheDir;

  // Map of video URLs to their download status and file information
  final Map<String, _CachedVideoInfo> _cachedVideos = {};

  // Stream controllers for download progress updates
  final Map<String, StreamController<double>> _progressControllers = {};

  /// Initialize the cache manager
  Future<void> initialize() async {
    if (_cacheDir != null) return; // Already initialized

    try {
      _cacheDir = await getApplicationDocumentsDirectory();
      final videoCacheDir = Directory('${_cacheDir!.path}/video_cache');
      if (!await videoCacheDir.exists()) {
        await videoCacheDir.create(recursive: true);
      }
      _cacheDir = videoCacheDir;

      // Load existing cached videos
      await _loadExistingCache();
    } catch (e) {
      debugPrint('Error initializing video cache: $e');
    }
  }

  /// Load existing cached videos from the cache directory
  Future<void> _loadExistingCache() async {
    try {
      final files = _cacheDir!.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.mp4')) {
          final infoFile = File('${file.path}.info');
          if (await infoFile.exists()) {
            final infoString = await infoFile.readAsString();
            final info = jsonDecode(infoString) as Map<String, dynamic>;
            final url = info['url'] as String;
            final totalSize = info['totalSize'] as int;
            final downloadedSize = await file.length();

            _cachedVideos[url] = _CachedVideoInfo(
              file: file,
              isComplete: downloadedSize >= totalSize,
              totalSize: totalSize,
              downloadedSize: downloadedSize,
            );
          }
        }
      }
      debugPrint('Loaded ${_cachedVideos.length} cached videos');
    } catch (e) {
      debugPrint('Error loading existing cache: $e');
    }
  }

  /// Get a hash of the URL to use as the filename
  String _getUrlHash(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if a video is cached (partially or completely)
  bool isVideoCached(String url) {
    return _cachedVideos.containsKey(url);
  }

  /// Check if a video is completely cached
  bool isVideoFullyCached(String url) {
    final info = _cachedVideos[url];
    return info != null && info.isComplete;
  }

  /// Get the cached file for a video URL
  File? getCachedFile(String url) {
    return _cachedVideos[url]?.file;
  }

  /// Get a stream of download progress for a video
  Stream<double> getDownloadProgress(String url) {
    if (!_progressControllers.containsKey(url)) {
      _progressControllers[url] = StreamController<double>.broadcast();
    }
    return _progressControllers[url]!.stream;
  }

  Future<VideoPlayerController> cacheVideo(String url) async {
    await initialize();

    if (_cachedVideos.containsKey(url) && _cachedVideos[url]!.isComplete) {
      // Video is already fully cached
      final file = _cachedVideos[url]!.file;
      return VideoPlayerController.file(file);
    }

    // Generate a filename based on the URL hash
    final filename = _getUrlHash(url);
    final filePath = '${_cacheDir!.path}/$filename.mp4';
    final infoPath = '${_cacheDir!.path}/$filename.mp4.info';
    final file = File(filePath);

    // Create or get progress controller
    if (!_progressControllers.containsKey(url)) {
      _progressControllers[url] = StreamController<double>.broadcast();
    }
    final progressController = _progressControllers[url]!;

    // If we have a partial download, we'll continue from there
    int startByte = 0;
    if (_cachedVideos.containsKey(url)) {
      startByte = _cachedVideos[url]!.downloadedSize;
    }

    // Start the download in the background
    _downloadVideo(url, file, infoPath, startByte, progressController);

    // Return a controller that will play the file as it's being downloaded
    if (startByte > 0) {
      // If we have partial content, play from file
      return VideoPlayerController.file(file);
    } else {
      // For initial content, start with network then switch to file once we have enough data
      // ignore: deprecated_member_use
      return VideoPlayerController.network(url);
    }
  }

  /// Download a video in the background
  Future<void> _downloadVideo(String url, File file, String infoPath,
      int startByte, StreamController<double> progressController) async {
    try {
      // Make a HEAD request to get the total size
      final headResponse = await http.head(Uri.parse(url));
      final totalSize =
          int.parse(headResponse.headers['content-length'] ?? '0');

      if (totalSize == 0) {
        debugPrint('Could not determine video size');
        return;
      }

      // Create info file
      final infoFile = File(infoPath);
      if (!await infoFile.exists()) {
        await infoFile.writeAsString(jsonEncode({
          'url': url,
          'totalSize': totalSize,
        }));
      }

      // Update cached video info
      _cachedVideos[url] = _CachedVideoInfo(
        file: file,
        isComplete: startByte >= totalSize,
        totalSize: totalSize,
        downloadedSize: startByte,
      );

      // If already complete, no need to download
      if (startByte >= totalSize) {
        progressController.add(1.0);
        return;
      }

      // Make a range request to continue the download
      final request = http.Request('GET', Uri.parse(url));
      request.headers['Range'] = 'bytes=$startByte-';

      final response = await http.Client().send(request);
      final fileStream = file.openWrite(
          mode: startByte > 0 ? FileMode.append : FileMode.write);

      int receivedBytes = startByte;
      final completer = Completer<void>();

      response.stream.listen(
        (data) {
          fileStream.add(data);
          receivedBytes += data.length;

          // Update progress
          final progress = receivedBytes / totalSize;
          progressController.add(progress);

          // Update cached info
          _cachedVideos[url] = _CachedVideoInfo(
            file: file,
            isComplete: receivedBytes >= totalSize,
            totalSize: totalSize,
            downloadedSize: receivedBytes,
          );
        },
        onDone: () async {
          await fileStream.flush();
          await fileStream.close();

          final isComplete = receivedBytes >= totalSize;
          _cachedVideos[url] = _CachedVideoInfo(
            file: file,
            isComplete: isComplete,
            totalSize: totalSize,
            downloadedSize: receivedBytes,
          );

          if (isComplete) {
            debugPrint('Video download complete: $url');
          } else {
            debugPrint(
                'Video partially downloaded: $url ($receivedBytes/$totalSize)');
          }

          completer.complete();
        },
        onError: (e) {
          debugPrint('Error downloading video: $e');
          fileStream.close();
          completer.completeError(e);
        },
        cancelOnError: true,
      );

      await completer.future;
    } catch (e) {
      debugPrint('Error caching video: $e');
    }
  }

  /// Clean up old cached videos that haven't been accessed recently
  Future<void> cleanupCache(
      {int maxCacheSizeBytes = 512 * 1024 * 1024}) async {}

  Future<void> clearCache() async {
    try {
      final dir = _cacheDir;
      if (dir != null && await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create();
      }
      _cachedVideos.clear();
      // Close and recreate all progress controllers
      for (var controller in _progressControllers.values) {
        await controller.close();
      }
      _progressControllers.clear();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}

/// Helper class to track cached video information
class _CachedVideoInfo {
  final File file;
  final bool isComplete;
  final int totalSize;
  final int downloadedSize;

  _CachedVideoInfo({
    required this.file,
    required this.isComplete,
    required this.totalSize,
    required this.downloadedSize,
  });
}

/// A wrapper for VideoPlayerController that handles cache management
class CachedVideoPlayerController {
  final String url;
  VideoPlayerController? controller;
  final VideoCacheManager _cacheManager;
  bool _isInitialized = false;
  final StreamController<VideoPlayerValue> _valueStreamController =
      StreamController<VideoPlayerValue>.broadcast();

  Stream<VideoPlayerValue> get valueStream => _valueStreamController.stream;
  bool get isInitialized => _isInitialized;
  VideoPlayerValue? get value => controller?.value;

  CachedVideoPlayerController(this.url) : _cacheManager = VideoCacheManager();

  /// Initialize the controller
  Future<void> initialize() async {
    try {
      // First check if the video is already cached
      if (_cacheManager.isVideoCached(url)) {
        final file = _cacheManager.getCachedFile(url);
        if (file != null) {
          controller = VideoPlayerController.file(file);
          await controller!.initialize();
          controller!.addListener(_controllerListener);
          _isInitialized = true;
          _valueStreamController.add(controller!.value);

          // If the video is only partially cached, continue downloading in background
          if (!_cacheManager.isVideoFullyCached(url)) {
            _cacheManager.cacheVideo(url);
          }
          return;
        }
      }

      // If not cached or partially cached, start caching
      controller = await _cacheManager.cacheVideo(url);
      await controller!.initialize();
      controller!.addListener(_controllerListener);
      _isInitialized = true;
      _valueStreamController.add(controller!.value);

      // Listen for download progress updates
      _cacheManager.getDownloadProgress(url).listen((progress) {
        // If download is complete and we started with network controller,
        // switch to file controller
        if (progress >= 1.0 &&
            controller is VideoPlayerController &&
            controller.toString().contains('network')) {
          _switchToFileController();
        }
      });
    } catch (e) {
      debugPrint('Error initializing cached video player: $e');
    }
  }

  void _controllerListener() {
    if (controller != null && _isInitialized) {
      _valueStreamController.add(controller!.value);
    }
  }

  /// Switch from network to file controller when caching is complete
  Future<void> _switchToFileController() async {
    try {
      final file = _cacheManager.getCachedFile(url);
      if (file != null) {
        final position = controller!.value.position;
        final wasPlaying = controller!.value.isPlaying;

        // Remove listener and dispose old controller
        controller!.removeListener(_controllerListener);
        await controller!.pause();
        await controller!.dispose();

        // Create new controller with file
        controller = VideoPlayerController.file(file);
        await controller!.initialize();
        await controller!.seekTo(position);
        if (wasPlaying) {
          await controller!.play();
        }
        controller!.addListener(_controllerListener);
        _valueStreamController.add(controller!.value);
      }
    } catch (e) {
      debugPrint('Error switching to file controller: $e');
    }
  }

  /// Play the video
  Future<void> play() async {
    await controller?.play();
  }

  /// Pause the video
  Future<void> pause() async {
    await controller?.pause();
  }

  /// Seek to a specific position
  Future<void> seekTo(Duration position) async {
    await controller?.seekTo(position);
  }

  /// Set the volume
  Future<void> setVolume(double volume) async {
    await controller?.setVolume(volume);
  }

  /// Set looping
  Future<void> setLooping(bool looping) async {
    await controller?.setLooping(looping);
  }

  /// Dispose the controller
  Future<void> dispose() async {
    controller?.removeListener(_controllerListener);
    await controller?.dispose();
    await _valueStreamController.close();
  }
}

/// Extension to make it easy to get a CachedVideoPlayerController
extension VideoCacheExtension on String {
  CachedVideoPlayerController get cachedVideoPlayerController {
    return CachedVideoPlayerController(this);
  }
}
