import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/data/models/nomeric_field_model.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NumericFieldBottomSheet extends StatefulWidget {
  final NomericFieldModel field;
  final Map<String, int>? initialValues;
  final Function(int?, int?) onRangeSelected;

  const NumericFieldBottomSheet({
    super.key,
    required this.field,
    required this.initialValues,
    required this.onRangeSelected,
  });

  @override
  State<NumericFieldBottomSheet> createState() =>
      _NumericFieldBottomSheetState();
}

class _NumericFieldBottomSheetState extends State<NumericFieldBottomSheet> {
  late TextEditingController _fromController;
  late TextEditingController _toController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController(
      text: widget.initialValues?['from']?.toString() ?? '',
    );
    _toController = TextEditingController(
      text: widget.initialValues?['to']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmoothClipRRect(
      smoothness: 0.8,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: const Offset(-4, 0),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 24,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        widget.onRangeSelected(null, null);
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.clear_,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    widget.field.fieldName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fromController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: InputDecoration(
                            labelText:   AppLocalizations.of(context)!.from,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (_) =>
                              setState(() => _errorMessage = null),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          width: 8,
                          height: 2,
                          color: Colors.grey[300],
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _toController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: InputDecoration(
                            labelText:   AppLocalizations.of(context)!.to,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (_) =>
                              setState(() => _errorMessage = null),
                        ),
                      ),
                    ],
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
              width: double.infinity,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final fromText = _fromController.text.trim();
                      final toText = _toController.text.trim();

                      int? from =
                          fromText.isEmpty ? null : int.tryParse(fromText);
                      int? to = toText.isEmpty ? null : int.tryParse(toText);

                      if (from != null && to != null && from > to) {
                        setState(() {
                          _errorMessage =
                                AppLocalizations.of(context)!.from_value_error;
                        });
                        return;
                      }

                      widget.onRangeSelected(from, to);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: SmoothRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context)!.apply,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.white,
                          fontFamily: Constants.Arial,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
