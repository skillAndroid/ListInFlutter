import 'package:flutter/material.dart';

class NoItemsFound extends StatelessWidget {
  const NoItemsFound({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No items found'),
    );
  }
}