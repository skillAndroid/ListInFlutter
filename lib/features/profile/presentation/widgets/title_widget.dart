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

  static const int _minLength = 10;
  static const int _maxLength = 100;

  @override
  void initState() {
    super.initState();
    final state = context.read<PublicationUpdateBloc>().state;
    _titleController = TextEditingController(text: state.title);
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
    final error = _validateInput(_titleController.text);
    if (error == null) {
      context
          .read<PublicationUpdateBloc>()
          .add(UpdateTitle(_titleController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicationUpdateBloc, PublicationUpdateState>(
      buildWhen: (previous, current) => previous.title != current.title,
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
                        counterText: '',
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
