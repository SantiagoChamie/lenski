import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/screens/home/competences/competence_icon.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';

/// A button widget for selecting a language learning competence.
///
/// This component displays a checkbox, competence name and icon for one of the four
/// language learning competences (reading, writing, speaking, listening). It allows 
/// users to toggle the selection of competences when creating a new course.
///
/// Features:
/// - Visual indication of selected state with checkbox
/// - Special handling for reading (always selected and disabled)
/// - Descriptive tooltip for reading competence
/// - Responsive sizing options (regular and small variants)
/// - Language-specific competence icons
class CompetenceSelectorButton extends StatefulWidget {
  /// The type of competence (must be one of: 'listening', 'speaking', 'reading', 'writing')
  final String competence;
  
  /// Callback function triggered when the competence is toggled
  final Function(String) onToggle;
  
  /// Whether the competence is initially selected
  final bool isSelected;
  
  /// Whether to display the button in a compact form
  final bool isSmall;

  /// Creates a CompetenceSelectorButton widget.
  /// 
  /// [competence] is the name of the competence to be displayed.
  /// [onToggle] is the callback function to be called when the competence is toggled.
  /// [isSelected] determines if the competence is initially selected.
  /// [isSmall] when true, displays the button in a compact form without the competence name.
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
  /// Whether the competence is currently selected
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

  /// Toggles the selected state of the competence.
  ///
  /// This method:
  /// 1. Updates the local selected state
  /// 2. Calls the onToggle callback to notify parent components
  /// 3. Does nothing if the competence is reading (which is always selected)
  void _toggleSelection() {
    // Don't allow toggling if it's reading
    if (widget.competence == "reading") return;

    setState(() {
      _isSelected = !_isSelected;
    });
    widget.onToggle(widget.competence);
  }

  /// Returns the localized name of the competence with proper capitalization.
  ///
  /// @param context The build context for accessing localization
  /// @param competence The competence identifier string
  /// @return The properly capitalized and localized competence name
  String _getCompetenceName(BuildContext context, String competence) {
    final localizations = AppLocalizations.of(context)!;
    
    switch (competence) {
      case "reading":
        return localizations.readingCompetence;
      case "writing":
        return localizations.writingCompetence;
      case "speaking":
        return localizations.speakingCompetence;
      case "listening":
        return localizations.listeningCompetence;
      default:
        return competence[0].toUpperCase() + competence.substring(1).toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final localizations = AppLocalizations.of(context)!;
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
              side: const BorderSide(color: AppColors.darkGrey, width: 1),
              value: _isSelected,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              checkColor: Colors.white,
              activeColor: AppColors.blue,
              onChanged: (bool? value) {
                _toggleSelection();
              },
            ),
          ),
          if(!widget.isSmall)
            SizedBox(width: p.standardPadding()),
          if(!widget.isSmall)
            Text(
              _getCompetenceName(context, widget.competence),
              style: TextStyle(
                fontSize: 20, 
                fontFamily: appFonts['Paragraph'], 
                color: AppColors.black
              ),
            ),
          if(!widget.isSmall)
            const SizedBox(width: 8),
          if (isReading && !widget.isSmall) 
            Tooltip(
              message: localizations.readingRequiredTooltip,
              child: const Icon(Icons.help_outline, color: AppColors.darkGrey),
            ),
          const Spacer(),
          CompetenceIcon(size: 50, type: widget.competence),
        ],
      ),
    );
  }
}