import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';

void showCustomModalBottomSheet({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  Widget Function(Widget)? containerWidget,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(18),
      ),
    ),
    builder: (context) {
      final content = builder(context);
      return containerWidget != null ? containerWidget(content) : content;
    },
  );
}
