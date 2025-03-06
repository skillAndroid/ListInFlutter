// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddTitlePage extends StatefulWidget {
  const AddTitlePage({super.key});

  @override
  State<AddTitlePage> createState() => _AddTitlePageState();
}

class _AddTitlePageState extends State<AddTitlePage> {
  late TextEditingController _titleController;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;
  bool _isDirty = false;

  static const int _minLength = 10;
  static const int _maxLength = 100;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PostProvider>(context, listen: false);
    _titleController = TextEditingController(text: provider.postTitle);
    _titleController.addListener(_onTextChanged);

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Initial validation
    _validateInput(_titleController.text);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (!_isFocused) {
        _isDirty = true;
      }
      _validateInput(_titleController.text);
    });
  }

  String? _validateInput(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorText = AppLocalizations.of(context)!.title_required;
      } else if (value.length < _minLength) {
        _errorText = AppLocalizations.of(context)!.title_min_length;
      } else if (value.length > _maxLength) {
        _errorText = AppLocalizations.of(context)!.title_min_length_warning;
      } else {
        _errorText = null;
      }
    });
    return _errorText;
  }

  void _onTextChanged() {
    setState(() {
      _isDirty = true;
      _validateInput(_titleController.text);
    });
    // Update provider immediately without debouncing
    Provider.of<PostProvider>(context, listen: false)
        .changePostTitle(_titleController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
              padding: EdgeInsets.only(bottom: 4.0, left: 2),
              child: Text(
                AppLocalizations.of(context)!.add_title_now,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: Constants.Arial,
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: SmoothClipRRect(
                smoothness: 1,
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: AppColors.containerColor,
                  width: 1,
                  style: BorderStyle.solid,
                ),
                child: TextField(
                  controller: _titleController,
                  focusNode: _focusNode,
                  maxLength: _maxLength,
                  decoration: InputDecoration(
                    fillColor: AppColors.containerColor.withOpacity(0.3),
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: AppLocalizations.of(context)!.example_title,
                    contentPadding: const EdgeInsets.all(14),
                    counterText: '',
                  ),
                ),
              ),
            ),
            if (_isDirty && _errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 2.0),
                child: Text(
                  _errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontFamily: Constants.Arial,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${_titleController.text.length}/$_maxLength',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontFamily: Constants.Arial,
                      color: _titleController.text.length > _maxLength
                          ? Colors.red
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
