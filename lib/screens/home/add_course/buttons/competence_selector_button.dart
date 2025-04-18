import 'package:flutter/material.dart';
import 'package:lenski/screens/home/competences/competence_icon.dart';
import 'package:lenski/utils/proportions.dart';

/// A button widget for selecting a competence.
class CompetenceSelectorButton extends StatefulWidget {
  final String competence;
  final Function(String) onToggle;

  /// Creates a CompetenceSelectorButton widget.
  /// 
  /// [competence] is the name of the competence to be displayed.
  /// [onToggle] is the callback function to be called when the competence is toggled.
  const CompetenceSelectorButton({super.key, required this.competence, required this.onToggle});

  @override
  _CompetenceSelectorButtonState createState() => _CompetenceSelectorButtonState();
}

class _CompetenceSelectorButtonState extends State<CompetenceSelectorButton> {
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    // Set reading to be selected by default
    _isSelected = widget.competence == "reading";
    
    // Use Future.microtask to schedule the callback after the build is complete
    if (_isSelected) {
      Future.microtask(() {
        widget.onToggle(widget.competence);
      });
    }
  }

  void _toggleSelection() {
    // Don't allow toggling if it's reading
    if (widget.competence == "reading") return;

    setState(() {
      _isSelected = !_isSelected;
    });
    widget.onToggle(widget.competence);
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final isReading = widget.competence == "reading";
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        fixedSize: Size(p.createCourseButtonWidth(), p.createCourseButtonHeight())
      ),
      onPressed: _toggleSelection,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 1.3, // Adjust the scale to make the checkbox bigger
            child: Checkbox(
              side: const BorderSide(color: Colors.grey, width: 1),
              value: _isSelected,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              checkColor: Colors.white,
              activeColor: const Color(0xFF2C73DE),
              onChanged: (bool? value) {
                _toggleSelection();
              },
            ),
          ),
          SizedBox(width: p.standardPadding()), // Space between checkbox and competence name
          Text(
            widget.competence[0].toUpperCase() + widget.competence.substring(1).toLowerCase(),
            style: const TextStyle(fontSize: 20, fontFamily: "Varela Round", color: Colors.black),
          ), // Competence name
          const SizedBox(width: 8),
          if (isReading) 
            Tooltip(
              message: "Reading is the base of LenSki's learning method.",
              child: Icon(Icons.help_outline, color: Colors.grey[600]),
            ),
          const Spacer(),
          CompetenceIcon(size: 50, type: widget.competence),
        ],
      ),
    );
  }
}