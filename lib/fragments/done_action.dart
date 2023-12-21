import 'package:flutter/material.dart';
import 'package:wing_cook/constants/app_theme.dart';

class DoneAction extends StatelessWidget {
  const DoneAction({super.key, required this.title, required this.onPressed});
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: ButtonStyleButton.allOrNull<Color>(primary),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          )),
    );
  }
}
