import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:list_in/core/utils/const.dart';

class ActionSheetOption {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;
  final bool isDestructive;

  const ActionSheetOption({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
    this.isDestructive = false,
  });
}

class ActionSheetMenu {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required List<ActionSheetOption> options,
  }) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          title,
          style: const TextStyle(fontFamily: Constants.Arial),
        ),
        message: Text(
          message,
          style: const TextStyle(fontFamily: Constants.Arial),
        ),
        actions: options
            .map(
              (option) => CupertinoActionSheetAction(
                isDestructiveAction: option.isDestructive,
                onPressed: () {
                  Navigator.of(context).pop();
                  option.onPressed();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option.icon,
                      color: option.iconColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option.title,
                      style: TextStyle(
                        color: option.isDestructive ? null : Colors.black,
                        fontWeight: FontWeight.w500,
                        fontFamily: Constants.Arial,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: const TextStyle(fontFamily: Constants.Arial, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
