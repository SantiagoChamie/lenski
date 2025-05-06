import 'package:flutter/material.dart';
import 'package:lenski/screens/home/competences/competence_icon.dart';
import 'package:lenski/utils/proportions.dart';

/// A button widget for selecting a competence.
class CompetenceSelectorButton extends StatefulWidget {
  final String competence;
  final Function(String) onToggle;
  final bool isSelected; // Add this parameter
  final bool isSmall;

  /// Creates a CompetenceSelectorButton widget.
  /// 
  /// [competence] is the name of the competence to be displayed.
  /// [onToggle] is the callback function to be called when the competence is toggled.
  /// [isSelected] determines if the competence is initially selected.
  const CompetenceSelectorButton({
    super.key, 
    required this.competence, 
    required this.onToggle, 
    this.isSelected = false, // Default to false
    this.isSmall = false,
  });

  @override
  _CompetenceSelectorButtonState createState() => _CompetenceSelectorButtonState();
}

class _CompetenceSelectorButtonState extends State<CompetenceSelectorButton> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    // Initialize selection state from widget parameter or default to reading
    _isSelected = widget.isSelected || widget.competence == "reading";
    
    // Use Future.microtask to schedule the callback after the build is complete
    if (_isSelected && !widget.isSelected) { // Only call if not explicitly set but selected by default
      Future.microtask(() {
        widget.onToggle(widget.competence);
      });
    }
  }

  @override
  void didUpdateWidget(CompetenceSelectorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selection state if the isSelected prop changes
    if (oldWidget.isSelected != widget.isSelected) {
      setState(() {
        _isSelected = widget.isSelected || widget.competence == "reading";
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
        fixedSize: Size(!widget.isSmall ? p.createCourseButtonWidth() : 150, p.createCourseButtonHeight()),
        backgroundColor: Colors.white,
        overlayColor: Colors.transparent
      ),
      onPressed: _toggleSelection,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 1.3,
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
          if(!widget.isSmall)
          SizedBox(width: p.standardPadding()),
          if(!widget.isSmall)
          Text(
            widget.competence[0].toUpperCase() + widget.competence.substring(1).toLowerCase(),
            style: const TextStyle(fontSize: 20, fontFamily: "Varela Round", color: Colors.black),
          ),
          if(!widget.isSmall)
          const SizedBox(width: 8),
          if (isReading && !widget.isSmall) 
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