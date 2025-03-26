// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddPricePage extends StatefulWidget {
  const AddPricePage({super.key});

  @override
  State<AddPricePage> createState() => _AddPricePageState();
}

class _AddPricePageState extends State<AddPricePage> {
  late TextEditingController _priceController;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String _lastCommittedText = '';
  bool _needsUpdate = false;
  Timer? _debounceTimer;
  String? _errorText;
// State variable to track the switch status

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PostProvider>(context, listen: false);
    // Only set initial text if price is greater than 0
    _lastCommittedText = provider.price > 0 ? provider.price.toString() : '';
    _priceController = TextEditingController(
        text: _lastCommittedText.isNotEmpty
            ? formatPrice(_lastCommittedText)
            : '');
    _priceController.addListener(_onTextChanged);

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        _validateInput(_priceController.text);
      });
    });
  }

  // Format price with thousands separator
  String formatPrice(String value) {
    if (value.isEmpty) return '';

    // Remove any existing spaces and non-digit characters
    value =
        value.replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r'[^\d]'), '');

    // Split into groups of 3 from the right
    final parts = [];
    for (var i = value.length; i > 0; i -= 3) {
      parts.insert(0, value.substring(i < 3 ? 0 : i - 3, i));
    }

    return parts.join(' ');
  }

  // Convert formatted price string to double
  double parsePrice(String value) {
    if (value.isEmpty) return 0.0;
    // Remove spaces and convert to double
    return double.tryParse(value.replaceAll(' ', '')) ?? 0.0;
  }

  String? _validateInput(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorText = null; // Don't show error for empty field initially
        return;
      }

      final price = parsePrice(value);
      if (price <= 0) {
        _errorText = AppLocalizations.of(context)!.price_greater_than_zero;
      } else if (price > 1000000000) {
        // Add your own maximum limit
        _errorText = AppLocalizations.of(context)!.price_too_high;
      } else {
        _errorText = null;
      }
    });
    return _errorText;
  }

  void _onTextChanged() {
    if (_priceController.text.isEmpty) {
      _lastCommittedText = '';
      _needsUpdate = true;
      _commitUpdate();
      return;
    }

    // Get cursor position before formatting
    final cursorPosition = _priceController.selection.start;
    final oldText = _priceController.text;

    // Format the text
    final formattedText = formatPrice(oldText);

    // Only update if the formatted text is different
    if (formattedText != oldText) {
      _priceController.text = formattedText;

      // Calculate new cursor position
      final newPosition =
          cursorPosition + (formattedText.length - oldText.length);
      _priceController.selection = TextSelection.fromPosition(
        TextPosition(offset: newPosition.clamp(0, formattedText.length)),
      );
    }

    _validateInput(formattedText);

    if (formattedText != _lastCommittedText) {
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
    final newText = _priceController.text;
    if (newText != _lastCommittedText) {
      final provider = Provider.of<PostProvider>(context, listen: false);
      provider.changePrice(parsePrice(newText));
      _lastCommittedText = newText;
      _needsUpdate = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text(
                AppLocalizations.of(context)!.enter_price,
                style: TextStyle(
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
                  style: _isFocused ? BorderStyle.solid : BorderStyle.none,
                ),
                child: TextField(
                  controller: _priceController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  cursorColor: Theme.of(context).primaryColor,
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
                    hintText: AppLocalizations.of(context)!.currency,
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
              padding: EdgeInsets.symmetric(
                vertical: 12,
              ),
              child: Text(
                AppLocalizations.of(context)!.negotiable_price_info,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    AppLocalizations.of(context)!.negotiable_price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: Constants.Arial,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    value: context.watch<PostProvider>().isNegatable,
                    onChanged: (bool value) {
                      context.read<PostProvider>().changeIsNegatable(value);
                    },
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
