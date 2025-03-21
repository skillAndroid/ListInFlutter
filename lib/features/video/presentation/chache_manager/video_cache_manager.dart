import 'dart:convert';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoCache {
  static final VideoCache _instance = VideoCache._internal();

  factory VideoCache() => _instance;

  VideoCache._internal();

  // Custom cache manager for better control
  final _cacheManager = CacheManager(
    Config(
      'videoCacheKey',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 50, // Adjust based on your app's needs
      repo: JsonCacheInfoRepository(databaseName: 'videoCache'),
      fileService: HttpFileService(),
    ),
  );

  // Keep track of videos being cached and their status
  final Map<String, bool> _cachingInProgress = {};

  // Keep track of preloaded controllers to reuse them
  final Map<String, BetterPlayerController> _preloadedControllers = {};

  // Queue for preloading to limit concurrent downloads
  final List<String> _preloadQueue = [];
  int _maxConcurrentDownloads = 2;
  int _currentDownloads = 0;

  // Function to generate a unique cache key for a URL
  String _generateCacheKey(String url) {
    var bytes = utf8.encode(url);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Check if a video is cached
  Future<bool> isVideoCached(String url) async {
    final fileInfo =
        await _cacheManager.getFileFromCache(_generateCacheKey(url));
    return fileInfo != null;
  }

  // Get cached file path if exists
  Future<String?> getCachedVideoPath(String url) async {
    final fileInfo =
        await _cacheManager.getFileFromCache(_generateCacheKey(url));
    return fileInfo?.file.path;
  }

  // Cache a video
  Future<File?> cacheVideo(String url) async {
    final cacheKey = _generateCacheKey(url);

    // Check if already cached
    final existingFile = await _cacheManager.getFileFromCache(cacheKey);
    if (existingFile != null) {
      return existingFile.file;
    }

    // Check if caching is already in progress
    if (_cachingInProgress[url] == true) {
      debugPrint('🔄 Caching already in progress for: $url');
      return null;
    }

    try {
      _cachingInProgress[url] = true;
      debugPrint('📥 Starting to cache video: $url');

      final fileInfo = await _cacheManager.downloadFile(
        url,
        key: cacheKey,
      );

      debugPrint('✅ Video cached successfully: $url');
      _cachingInProgress[url] = false;
      return fileInfo.file;
    } catch (error) {
      debugPrint('❌ Failed to cache video: $url\n└─ Error: $error');
      _cachingInProgress[url] = false;
      return null;
    }
  }

  // Create or get a preloaded BetterPlayerController for a URL
  Future<BetterPlayerController?> getPreloadedController(String url) async {
    // Return existing controller if available
    if (_preloadedControllers.containsKey(url)) {
      return _preloadedControllers[url];
    }

    // Check if we have a cached file
    final cachedPath = await getCachedVideoPath(url);

    // Create data source based on cached status
    BetterPlayerDataSource dataSource;
    if (cachedPath != null) {
      debugPrint('🎬 Creating controller from cache: $url');
      dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        cachedPath,
        cacheConfiguration:
            const BetterPlayerCacheConfiguration(useCache: false),
      );
    } else {
      debugPrint('🎬 Creating controller from network: $url');
      dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        cacheConfiguration:
            const BetterPlayerCacheConfiguration(useCache: true),
      );

      // Start caching for future use
      _queueForCaching(url);
    }

    // Create and initialize controller
    final betterPlayerConfiguration = BetterPlayerConfiguration(
      autoPlay: false,
      looping: true,
      handleLifecycle: false,
      placeholder: const Center(child: CircularProgressIndicator()),
    );

    final controller = BetterPlayerController(betterPlayerConfiguration);
    await controller.setupDataSource(dataSource);

    // Store for later reuse
    _preloadedControllers[url] = controller;

    return controller;
  }

  // Preload a batch of videos for smooth scrolling
  void preloadVideos(List<String> urls) {
    for (final url in urls) {
      if (!_preloadQueue.contains(url) &&
          !_cachingInProgress.containsKey(url)) {
        _preloadQueue.add(url);
      }
    }
    _processPreloadQueue();
  }

  // Add a video to the caching queue
  void _queueForCaching(String url) {
    if (!_preloadQueue.contains(url) && !_cachingInProgress.containsKey(url)) {
      _preloadQueue.add(url);
      _processPreloadQueue();
    }
  }

  // Process the preload queue
  void _processPreloadQueue() async {
    if (_preloadQueue.isEmpty || _currentDownloads >= _maxConcurrentDownloads) {
      return;
    }

    _currentDownloads++;
    final url = _preloadQueue.removeAt(0);

    try {
      await cacheVideo(url);
    } finally {
      _currentDownloads--;
      // Continue processing queue
      _processPreloadQueue();
    }
  }

  // Clear a specific video from cache
  Future<void> clearVideo(String url) async {
    final cacheKey = _generateCacheKey(url);
    await _cacheManager.removeFile(cacheKey);

    if (_preloadedControllers.containsKey(url)) {
      _preloadedControllers[url]?.dispose();
      _preloadedControllers.remove(url);
    }
  }

  // Dispose a controller when no longer needed
  void disposeController(String url) {
    if (_preloadedControllers.containsKey(url)) {
      _preloadedControllers[url]?.dispose();
      _preloadedControllers.remove(url);
    }
  }

  // Clear entire cache
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();

    // Dispose all controllers
    for (final controller in _preloadedControllers.values) {
      controller.dispose();
    }
    _preloadedControllers.clear();
    _cachingInProgress.clear();
    _preloadQueue.clear();
    _currentDownloads = 0;
  }
}
