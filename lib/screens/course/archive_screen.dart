import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/proportions.dart';

class ArchiveScreen extends StatefulWidget {
  final Course course;

  const ArchiveScreen({super.key, required this.course});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final boxPadding = p.standardPadding() * 4;
    const iconSize = 80.0;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(boxPadding),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0F6),
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'The Archive - Coming Soon',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "Unbounded"
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: boxPadding - iconSize / 3,
          left: boxPadding - iconSize / 3,
          child: FlagIcon(
            size: iconSize,
            borderWidth: 5.0,
            borderColor: const Color(0xFFD9D0DB),
            imageUrl: widget.course.imageUrl,
          ),
        ),
        Positioned(
          top: boxPadding + 10,
          right: boxPadding + 10,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ),
      ],
    );
  }
}