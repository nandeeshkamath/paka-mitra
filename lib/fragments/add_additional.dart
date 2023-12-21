import 'package:flutter/material.dart';
import 'package:wing_cook/constants/app_theme.dart';

class AddAdditional extends StatelessWidget {
  const AddAdditional({super.key, required this.title, required this.onPressed});
  final VoidCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(
            Icons.add,
            color: tertiary,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 15, color: tertiary),
          ),
        ],
      ),
    );
  }
}
