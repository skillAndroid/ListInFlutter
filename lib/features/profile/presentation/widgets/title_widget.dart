import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_state.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class AddTitleWidget extends StatefulWidget {
  const AddTitleWidget({super.key});

  @override
  State<AddTitleWidget> createState() => _AddTitlePageState();
}

class _AddTitlePageState extends State<AddTitleWidget> {
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
    final state = context.read<PublicationUpdateBloc>().state;
    _titleController = TextEditingController(text: state.title);
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
    if (value.isEmpty) {
      _errorText = 'Title is required';
    } else if (value.length < _minLength) {
      _errorText = 'Title must be at least $_minLength characters (${value.length}/$_minLength)';
    } else if (value.length > _maxLength) {
      _errorText = 'Title cannot exceed $_maxLength characters';
    } else {
      _errorText = null;
    }
    return _errorText;
  }

  void _onTextChanged() {
    setState(() {
      _isDirty = true;
      _validateInput(_titleController.text);
    });
    context.read<PublicationUpdateBloc>().add(UpdateTitle(_titleController.text));
  }

  Color _getBorderColor() {
    if (!_isDirty && !_isFocused) return Colors.transparent;
    if (_errorText != null) return Colors.red;
    if (_isFocused) return AppColors.black;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicationUpdateBloc, PublicationUpdateState>(
      buildWhen: (previous, current) => previous.title != current.title,
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
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
                      color: _getBorderColor(),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    child: TextField(
                      controller: _titleController,
                      focusNode: _focusNode,
                      maxLength: _maxLength,
                      onChanged: (value) => _onTextChanged(),
                      decoration: InputDecoration(
                        fillColor: AppColors.containerColor,
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
                        hintText: 'For example: Iphone 15 pro',
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
                        fontFamily: "Syne",
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
                          fontFamily: "Syne",
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
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}