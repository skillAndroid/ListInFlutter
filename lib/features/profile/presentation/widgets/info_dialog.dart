import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:list_in/core/utils/const.dart';

class InfoDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showCupertinoDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.ok,
              style: const TextStyle(fontFamily: Constants.Arial),
            ),
          ),
        ],
      ),
    );
  }
}
