import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryImagePicker extends StatefulWidget {
  const GalleryImagePicker({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GalleryImagePickerState createState() => _GalleryImagePickerState();
}

class _GalleryImagePickerState extends State<GalleryImagePicker> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _images;

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      setState(() {
        _images = pickedFiles;
      });
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Images',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _pickImagesFromGallery();
                },
                child: const Text('Open Gallery'),
              ),
              const SizedBox(height: 16),
              _images != null
                  ? _buildImageGrid()
                  : const Text('No images selected'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageGrid() {
    return SizedBox(
      height: 300, // Adjust height as needed
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _images?.length ?? 0,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              
            },
            child: Image.file(
              File(_images![index].path),
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Image Picker'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showImagePickerBottomSheet,
          child: const Text('Pick Images'),
        ),
      ),
    );
  }
}