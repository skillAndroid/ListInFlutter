// ignore_for_file: deprecated_member_use, use_super_parameters
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  final String status;
  final bool showTail;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
    required this.status,
    this.showTail = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert status to uppercase for consistent comparison
    final upperStatus = status.toUpperCase();

    // Determine icon to show based on message status
    Icon? statusIcon;
    if (isMe) {
      if (upperStatus == 'VIEWED' || upperStatus == 'READ') {
        // Message has been read/viewed
        statusIcon = Icon(
          Icons.done_all,
          size: 13,
          color: AppColors.white.withOpacity(0.7),
        );
      } else if (upperStatus == 'DELIVERED') {
        // Message has been delivered but not read
        statusIcon = Icon(
          Icons.done,
          size: 13,
          color: AppColors.white.withOpacity(0.7),
        );
      } else {
        statusIcon = Icon(
          CupertinoIcons.time,
          size: 13,
          color: AppColors.black.withOpacity(0.7),
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(
        top: 0.75,
        bottom: 0.75,
        left: isMe ? 64 : 0,
        right: isMe ? 0 : 64,
      ),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : Theme.of(context).cardColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isMe || !showTail
                    ? const Radius.circular(20)
                    : const Radius.circular(4),
                bottomRight: !isMe || !showTail
                    ? const Radius.circular(20)
                    : const Radius.circular(4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe
                        ? AppColors.white
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe
                            ? AppColors.white.withOpacity(0.7)
                            : Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.7),
                      ),
                    ),
                    if (isMe) const SizedBox(width: 4),
                    if (isMe && statusIcon != null) statusIcon,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
