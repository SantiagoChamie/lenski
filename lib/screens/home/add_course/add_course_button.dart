import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';

class AddCourseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddCourseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: p.sidebarButtonWidth(),
          child: Container(
            constraints: const BoxConstraints.expand(width: double.infinity),
            child: IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.black,
                size: 30,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD9D0DB), // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(33), // Square appearance
                ),
              ),
              onPressed: onPressed,
            ),
          ),
        ),
      ],
    );
  }
}