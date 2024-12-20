import 'dart:async';
import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class AddTitlePage extends StatefulWidget {
  const AddTitlePage({super.key});

  @override
  State<AddTitlePage> createState() => _AddTitlePageState();
}

class _AddTitlePageState extends State<AddTitlePage> {
  late TextEditingController _titleController;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String _lastCommittedText = '';
  bool _needsUpdate = false;
  Timer? _debounceTimer;
  String? _errorText;

  static const int _minLength = 10;
  static const int _maxLength = 100;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PostProvider>(context, listen: false);
    _lastCommittedText = provider.postTitle;
    _titleController = TextEditingController(text: _lastCommittedText);
    _titleController.addListener(_onTextChanged);

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        _validateInput(_titleController.text);
      });
    });
  }

  String? _validateInput(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorText = 'Title is required';
      } else if (value.length < _minLength) {
        _errorText = 'Title must be at least $_minLength characters';
      } else if (value.length > _maxLength) {
        _errorText = 'Title cannot exceed $_maxLength characters';
      } else {
        _errorText = null;
      }
    });
    return _errorText;
  }

  void _onTextChanged() {
    _validateInput(_titleController.text);
    if (_titleController.text != _lastCommittedText) {
      _needsUpdate = true;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (_needsUpdate && mounted) {
          _commitUpdate();
        }
      });
    }
  }

  void _commitUpdate() {
    if (!mounted) return;
    final newText = _titleController.text;
    if (newText != _lastCommittedText && _errorText == null) {
      final provider = Provider.of<PostProvider>(context, listen: false);
      provider.changePostTitle(newText);
      _lastCommittedText = newText;
      _needsUpdate = false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.removeListener(_onTextChanged);
    if (_needsUpdate) {
      _commitUpdate();
    }
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 4.0, left: 2),
              child: Text(
                'Ok! Add title now...',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Syne",
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: SmoothClipRRect(
                smoothness: 1,
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: _errorText != null ? Colors.red : AppColors.black,
                  width: 2,
                  style: _isFocused ? BorderStyle.solid : BorderStyle.none,
                ),
                child: TextField(
                  controller: _titleController,
                  focusNode: _focusNode,
                  maxLength: _maxLength,
                  decoration: const InputDecoration(
                    fillColor: AppColors.containerColor,
                    border: OutlineInputBorder(),
                    hintText: 'For example: Iphone 15 pro',
                    contentPadding: EdgeInsets.all(14),
                    //  errorText: _errorText,
                    counterText: '', // Remove built-in counter
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 2.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_titleController.text.length}/$_maxLength',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontFamily: "Syne",
                    color: _titleController.text.length > _maxLength
                        ? Colors.red
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
