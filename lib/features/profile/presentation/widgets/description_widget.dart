// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_state.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  bool _isDirty = false;
  Timer? _debounceTimer;

  static const int _minLength = 30;
  static const int _maxLength = 2500;

  @override
  void initState() {
    super.initState();
    final state = context.read<PublicationUpdateBloc>().state;
    _descriptionController = TextEditingController(text: state.description);
    _descriptionController.addListener(_onTextChanged);

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Initial validation
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
    if (value.isEmpty) {
      _errorText = AppLocalizations.of(context)!.description_required;
    } else if (value.length < _minLength) {
      _errorText = AppLocalizations.of(context)!.description_min_length_warning;
    } else if (value.length > _maxLength) {
      _errorText = AppLocalizations.of(context)!.description_max_length;
    } else {
      _errorText = null;
    }
    return _errorText;
  }

  void _onTextChanged() {
    setState(() {
      _isDirty = true;
      _validateInput(_descriptionController.text);
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      context
          .read<PublicationUpdateBloc>()
          .add(UpdateDescription(_descriptionController.text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicationUpdateBloc, PublicationUpdateState>(
      buildWhen: (previous, current) =>
          previous.description != current.description,
      builder: (context, state) {
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
                    AppLocalizations.of(context)!.next_add_description,
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
                      onChanged: (value) => _onTextChanged(),
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
                        hintText:
                            AppLocalizations.of(context)!.example_description,
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
