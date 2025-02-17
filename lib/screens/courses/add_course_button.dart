import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';

class AddCourseButton extends StatelessWidget {
  const AddCourseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return SizedBox(
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
          onPressed: () {
            // Add your onPressed code here!
          },
        ),
      ),
    );
  }
}