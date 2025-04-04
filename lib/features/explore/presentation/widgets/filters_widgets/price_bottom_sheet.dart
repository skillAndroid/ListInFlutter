import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PriceRangeBottomSheet extends StatefulWidget {
  final String page;
  const PriceRangeBottomSheet({
    super.key,
    required this.page,
  });

  @override
  _PriceRangeBottomSheetState createState() => _PriceRangeBottomSheetState();
}

class _PriceRangeBottomSheetState extends State<PriceRangeBottomSheet> {
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late HomeTreeState currentState;

  @override
  void initState() {
    super.initState();
    currentState = context.read<HomeTreeCubit>().state;
    _fromController = TextEditingController(
      text: currentState.priceFrom?.toInt().toString() ?? '',
    );
    _toController = TextEditingController(
      text: currentState.priceTo?.toInt().toString() ?? '',
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _onFromChanged(String value) {
    final formatted = formatPrice(value);
    if (formatted != value) {
      _fromController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _onToChanged(String value) {
    final formatted = formatPrice(value);
    if (formatted != value) {
      _toController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipSmoothRect(
      radius: SmoothBorderRadius(
        cornerRadius: 14,
        cornerSmoothing: 0.8,
      ),
      child: Container(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with close button and title
            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(-4, 0),
                      child: IconButton(
                        icon: Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.only(),
                        constraints: BoxConstraints(),
                        splashRadius: 24,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.read<HomeTreeCubit>().clearPriceRange();
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
                  // Centered title
                  Text(
                    AppLocalizations.of(context)!.price_range,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Price range inputs
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    //
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fromController,
                          keyboardType: TextInputType.number,
                          onChanged: _onFromChanged,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.from,
                            prefixText: '\$ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          width: 8,
                          height: 2,
                          color: Colors.grey[300],
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _toController,
                          keyboardType: TextInputType.number,
                          onChanged: _onToChanged,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.to,
                            prefixText: '\$ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Apply button at the bottom
            Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
              width: double.infinity,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final from = double.tryParse(
                          _fromController.text.replaceAll(' ', ''));
                      final to = double.tryParse(
                          _toController.text.replaceAll(' ', ''));
                      context.read<HomeTreeCubit>().setPriceRange(
                            from,
                            to,
                            widget.page,
                          );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 30,
                          cornerSmoothing: 0.8,
                        ),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context)!.apply,
                        style: TextStyle(
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
            SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
