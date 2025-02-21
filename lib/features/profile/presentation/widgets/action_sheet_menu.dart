import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    String cancelText = 'Cancel',
  }) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          title,
          style: const TextStyle(fontFamily: "Poppins"),
        ),
        message: Text(
          message,
          style: const TextStyle(fontFamily: "Poppins"),
        ),
        actions: options.map((option) => 
          CupertinoActionSheetAction(
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
                    fontFamily: "Poppins",
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            cancelText,
            style: const TextStyle(fontFamily: "Poppins", fontSize: 16),
          ),
        ),
      ),
    );
  }
}