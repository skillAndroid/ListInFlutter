import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:list_in/core/utils/const.dart';

class ConfirmationDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    bool isDestructiveAction = true,
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontFamily: Constants.Arial),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: Constants.Arial),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructiveAction,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(fontFamily: Constants.Arial),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
