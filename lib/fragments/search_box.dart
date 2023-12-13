import 'package:flutter/material.dart';
import 'package:wing_cook/constants/app_theme.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({Key? key, required this.onTap}) : super(key: key);
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: secondary),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 50,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Text(
            "Search",
            textScaleFactor: 1.2,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
