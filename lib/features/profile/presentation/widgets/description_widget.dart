import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_state.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class AddDescriptionWidget extends StatefulWidget {
  const AddDescriptionWidget({super.key});

  @override
  State<AddDescriptionWidget> createState() => _AddDescriptionPageState();
}
class _AddDescriptionPageState extends State<AddDescriptionWidget> {
  late TextEditingController _descriptionController;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;
  Timer? _debounceTimer;

  static const int _minLength = 45;
  static const int _maxLength = 500;

  @override
  void initState() {
    super.initState();
    final state = context.read<PublicationUpdateBloc>().state;
    _descriptionController = TextEditingController(text: state.description);
    _descriptionController.addListener(_onTextChanged);

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        _validateInput(_descriptionController.text);
      });
    });
  }

  String? _validateInput(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorText = 'Description is required';
      } else if (value.length < _minLength) {
        _errorText = 'Description must be at least $_minLength characters';
      } else if (value.length > _maxLength) {
        _errorText = 'Description cannot exceed $_maxLength characters';
      } else {
        _errorText = null;
      }
    });
    return _errorText;
  }

  void _onTextChanged() {
    _validateInput(_descriptionController.text);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_errorText == null) {
        context
            .read<PublicationUpdateBloc>()
            .add(UpdateDescription(_descriptionController.text));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicationUpdateBloc, PublicationUpdateState>(
      buildWhen: (previous, current) =>
          previous.description != current.description,
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 4.0, left: 2),
                  child: Text(
                    'Next, add description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Syne",
                    ),
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: SmoothClipRRect(
                    smoothness: 1,
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: _errorText != null ? Colors.red : AppColors.black,
                      width: 2,
                      style: _isFocused ? BorderStyle.solid : BorderStyle.none,
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      focusNode: _focusNode,
                      maxLength: _maxLength,
                      maxLines: 15,
                      decoration: const InputDecoration(
                        fillColor: AppColors.containerColor,
                        border: OutlineInputBorder(),
                        hintText:
                            'For example: Selling iPhone 15 pro, unused and silver color',
                        contentPadding: EdgeInsets.all(14),
                        counterText: '',
                      ),
                    ),
                  ),
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, right: 2.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_descriptionController.text.length}/$_maxLength',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontFamily: "Syne",
                        color: _descriptionController.text.length > _maxLength
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
