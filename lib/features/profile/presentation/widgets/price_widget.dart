// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_state.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddPriceWidget extends StatefulWidget {
  const AddPriceWidget({super.key});

  @override
  State<AddPriceWidget> createState() => _AddPricePageState();
}

class _AddPricePageState extends State<AddPriceWidget> {
  late TextEditingController _priceController;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final state = context.read<PublicationUpdateBloc>().state;
    _priceController = TextEditingController(
        text: state.price > 0 ? formatPrice(state.price.toString()) : '');
    _priceController.addListener(_onTextChanged);
//
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        _validateInput(_priceController.text);
      });
    });
  }

  String formatPrice(String value) {
    if (value.isEmpty) return '';
    value =
        value.replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r'[^\d]'), '');
    final parts = [];
    for (var i = value.length; i > 0; i -= 3) {
      parts.insert(0, value.substring(i < 3 ? 0 : i - 3, i));
    }
    return parts.join(' ');
  }

  double parsePrice(String value) {
    if (value.isEmpty) return 0.0;
    return double.tryParse(value.replaceAll(' ', '')) ?? 0.0;
  }

  String? _validateInput(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorText = null;
        return;
      }

      final price = parsePrice(value);
      if (price <= 0) {
        _errorText = AppLocalizations.of(context)!.price_greater_than_zero;
      } else if (price > 1000000000) {
        _errorText = AppLocalizations.of(context)!.price_too_high;
      } else {
        _errorText = null;
      }
    });
    return _errorText;
  }

  void _onTextChanged() {
    final cursorPosition = _priceController.selection.start;
    final oldText = _priceController.text;
    final formattedText = formatPrice(oldText);

    if (formattedText != oldText) {
      _priceController.text = formattedText;
      final newPosition =
          cursorPosition + (formattedText.length - oldText.length);
      _priceController.selection = TextSelection.fromPosition(
        TextPosition(offset: newPosition.clamp(0, formattedText.length)),
      );
    }

    _validateInput(formattedText);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_errorText == null) {
        context
            .read<PublicationUpdateBloc>()
            .add(UpdatePrice(parsePrice(formattedText)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicationUpdateBloc, PublicationUpdateState>(
      buildWhen: (previous, current) =>
          previous.price != current.price ||
          previous.canBargain != current.canBargain,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    AppLocalizations.of(context)!.enter_price,
                    style: const TextStyle(
                      fontSize: 16,
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
                      color: Theme.of(context).cardColor,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                    child: TextField(
                      controller: _priceController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Theme.of(context).cardColor.withOpacity(0.5),
                        filled: true,
                        border: OutlineInputBorder(),
                        hintText: AppLocalizations.of(context)!.currency_uzs,
                        contentPadding: EdgeInsets.all(14),
                        counterText: '',
                      ),
                    ),
                  ),
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    AppLocalizations.of(context)!.negotiable_price_info,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.negotiable_price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: Constants.Arial,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: state.canBargain,
                        onChanged: (value) {
                          context
                              .read<PublicationUpdateBloc>()
                              .add(UpdateBargain(value));
                        },
                        activeTrackColor: AppColors.green,
                      ),
                    ),
                  ],
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
    _priceController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
