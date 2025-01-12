// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';



class ProductImagesDetailed extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String heroTag;

  const ProductImagesDetailed({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.heroTag,
  });

  @override
  State<ProductImagesDetailed> createState() => _ProductImagesDetailedState();
}

class _ProductImagesDetailedState extends State<ProductImagesDetailed> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildBackButton(),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 3.0,
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          _buildImageCounter(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 8),
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Colors.white.withOpacity(0.2),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              height: 40,
              width: 40,
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCounter() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: SmoothClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.black54,
            child: Text(
              '${_currentIndex + 1}/${widget.images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}