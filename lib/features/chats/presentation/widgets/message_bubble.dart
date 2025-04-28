// ignore_for_file: deprecated_member_use, use_super_parameters

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
    return Container(
      margin: EdgeInsets.only(
        top: 2,
        bottom: 2,
        left: isMe ? 64 : 0,
        right: isMe ? 0 : 64,
      ),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primaryLight2 // WhatsApp green for own messages
                  : Colors.white,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (isMe)
                      Icon(
                        status == 'READ' ? Icons.done_all : Icons.done,
                        size: 13,
                        color:
                            status == 'READ' ? Colors.blue : Colors.grey[600],
                      ),
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
