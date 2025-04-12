// CharacteristicItemWidget - For displaying individual characteristic item
import 'package:flutter/material.dart';

class CharacteristicItemWidget extends StatelessWidget {
  final String label;
  final String value;

  const CharacteristicItemWidget({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              '$label: ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
