// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class AddDescriptionPage extends StatefulWidget {
  const AddDescriptionPage({super.key});

  @override
  State<AddDescriptionPage> createState() => _AddDescriptionPageState();
}

class _AddDescriptionPageState extends State<AddDescriptionPage> {
  late TextEditingController _descriptionController;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;
  bool _isDirty = false;

  // These could be moved to constants and potentially localized
  static const int _minLength = 30;
  static const int _maxLength = 2500;

  // Fallback texts in case localization fails
  final String _fallbackDescriptionRequired = "Description is required";
  final String _fallbackMinLengthWarning =
      "Description must be at least 30 characters";
  final String _fallbackMaxLengthWarning =
      "Description must be less than 2500 characters";
  final String _fallbackAddDescription = "Add Description";
  final String _fallbackExampleDescription = "Describe your post...";

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PostProvider>(context, listen: false);
    _descriptionController =
        TextEditingController(text: provider.postDescription);
    _descriptionController.addListener(_onTextChanged);

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Initial validation will happen in first build
    // to avoid context issues in initState
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe to do validation here as context is available
    _validateInput(_descriptionController.text);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (!_isFocused) {
        _isDirty = true;
      }
      _validateInput(_descriptionController.text);
    });
  }

  String? _validateInput(String value) {
    final localizations = AppLocalizations.of(context);

    setState(() {
      if (value.isEmpty) {
        _errorText =
            localizations?.description_required ?? _fallbackDescriptionRequired;
      } else if (value.length < _minLength) {
        _errorText = localizations?.description_min_length_warning ??
            _fallbackMinLengthWarning;
      } else if (value.length > _maxLength) {
        _errorText =
            localizations?.description_max_length ?? _fallbackMaxLengthWarning;
      } else {
        _errorText = null;
      }
    });
    return _errorText;
  }

  void _onTextChanged() {
    setState(() {
      _isDirty = true;
      _validateInput(_descriptionController.text);
    });
    // Update provider immediately without debouncing
    Provider.of<PostProvider>(context, listen: false)
        .changePostDescription(_descriptionController.text);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 2),
              child: Text(
                localizations?.next_add_description ?? _fallbackAddDescription,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: Constants.Arial,
                ),
              ),
            ),
            SizedBox(
              height: 250,
              child: SmoothClipRRect(
                smoothness: 1,
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).cardColor,
                  width: 1,
                  style: BorderStyle.solid,
                ),
                child: TextField(
                  controller: _descriptionController,
                  focusNode: _focusNode,
                  maxLength: _maxLength,
                  maxLines: 15,
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).cardColor.withOpacity(0.3),
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
                    hintText: localizations?.example_description ??
                        _fallbackExampleDescription,
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
                    '${_descriptionController.text.length}/$_maxLength',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontFamily: Constants.Arial,
                      color: _descriptionController.text.length > _maxLength
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
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
