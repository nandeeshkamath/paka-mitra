import 'package:flutter/material.dart';
import 'package:wing_cook/constants/app_theme.dart';

class BottomButton extends StatelessWidget {
  const BottomButton({Key? key, required this.title, required this.onPressed})
      : super(key: key);
  final VoidCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
          elevation: const MaterialStatePropertyAll(10),
          fixedSize: MaterialStatePropertyAll(
            Size(MediaQuery.sizeOf(context).width, 60),
          ),
          backgroundColor: const MaterialStatePropertyAll(secondary),
          overlayColor: const MaterialStatePropertyAll(primary),
          shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
      child: Text(
        title,
        style: const TextStyle(
          color: primary,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
