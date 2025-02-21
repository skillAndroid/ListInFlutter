import 'package:flutter/cupertino.dart';

class InfoDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontFamily: "Poppins"),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: "Poppins"),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              buttonText,
              style: const TextStyle(fontFamily: "Poppins"),
            ),
          ),
        ],
      ),
    );
  }
}