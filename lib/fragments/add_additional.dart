import 'package:flutter/material.dart';

class AddAdditional extends StatelessWidget {
  const AddAdditional({Key? key, required this.title, required this.onPressed})
      : super(key: key);
  final VoidCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.add),
          const SizedBox(
            width: 5,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
