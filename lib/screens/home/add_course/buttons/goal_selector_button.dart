import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Defines the available goal types for reading
enum GoalType {
  /// Finding x new words
  learn,
  
  /// Study x days
  daily,
  
  /// Study for x hours
  time
}

/// A button widget for selecting a course goal.
///
/// This component allows users to select both the type of goal (word count, days, or time)
/// and the numeric value for that goal. It displays differently based on whether it's being
/// used for daily goals or total goals.
///
/// Features:
/// - Text field for entering numeric values
/// - Goal type selection via popup dialog
/// - Automatic formatting based on goal type
/// - Different appearance for daily vs. total goals
class GoalSelectorButton extends StatefulWidget {
  /// Callback function triggered when the numeric value changes
  final Function(int) onValueChanged;
  
  /// Callback function triggered when the goal type changes
  final Function(GoalType)? onGoalTypeChanged;
  
  /// Initial numeric value for the goal
  final int initialValue;
  
  /// Whether this is for daily goals (true) or total goals (false)
  final bool isDaily;
  
  /// Initial goal type to display
  final GoalType initialGoalType;

  /// Creates a GoalSelectorButton widget.
  /// 
  /// [initialValue] is the initial number of words.
  /// [onValueChanged] is the callback function that is called when the goal value changes.
  /// [onGoalTypeChanged] is called when the goal type changes.
  /// [isDaily] determines if this shows daily goals or global goals.
  /// [initialGoalType] sets the initial goal type.
  const GoalSelectorButton({
    super.key, 
    required this.onValueChanged,
    this.onGoalTypeChanged,
    this.initialValue = 100,
    this.isDaily = true, // Default to daily mode
    this.initialGoalType = GoalType.learn, // Default to learn goal type
  });

  @override
  _GoalSelectorButtonState createState() => _GoalSelectorButtonState();
}

class _GoalSelectorButtonState extends State<GoalSelectorButton> {
  /// Controller for the goal value text field
  late TextEditingController _controller;
  
  /// Focus node for the goal value text field
  late FocusNode _focusNode;
  
  /// Currently selected goal type
  late GoalType _goalType;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
    _focusNode = FocusNode();
    _goalType = widget.initialGoalType;
    
    // Call the callback with initial value
    Future.microtask(() {
      widget.onValueChanged(widget.initialValue);
      if (widget.onGoalTypeChanged != null) {
        widget.onGoalTypeChanged!(_goalType);
      }
    });
  }

  /// Updates state when widget properties change.
  ///
  /// This ensures the goal type stays in sync with the parent widget's value.
  @override
  void didUpdateWidget(GoalSelectorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update _goalType if the initialGoalType has changed
    if (oldWidget.initialGoalType != widget.initialGoalType) {
      setState(() {
        _goalType = widget.initialGoalType;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  /// Displays a dialog for selecting a goal type.
  ///
  /// The dialog shows the three available goal types with descriptions
  /// and allows the user to select one.
  void _showGoalTypeSelector(BuildContext context) {
    final p = Proportions(context);
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: p.createCourseButtonWidth() * 1.2,
            height: 300, // Increased height to better fit options
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    localizations.selectGoalType,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: appFonts['Subtitle'],
                      color: AppColors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildGoalTypeOption(
                        context, 
                        GoalType.learn, 
                        localizations.goalTypeLearnTitle, 
                        localizations.goalTypeLearnDescription,
                        Icons.psychology
                      ),
                      _buildGoalTypeOption(
                        context, 
                        GoalType.daily, 
                        localizations.goalTypeDailyTitle, 
                        localizations.goalTypeDailyDescription,
                        Icons.calendar_today
                      ),
                      _buildGoalTypeOption(
                        context, 
                        GoalType.time, 
                        localizations.goalTypeTimeTitle, 
                        localizations.goalTypeTimeDescription,
                        Icons.timer
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Builds a single goal type option for the selector dialog.
  ///
  /// @param context The build context
  /// @param type The goal type this option represents
  /// @param title The title text for this option
  /// @param subtitle The descriptive text for this option
  /// @param icon The icon to display for this option
  /// @return A widget representing the goal type option
  Widget _buildGoalTypeOption(BuildContext context, GoalType type, String title, String subtitle, IconData icon) {
    final bool isSelected = type == _goalType;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isSelected ? AppColors.lightGrey : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() { 
              _goalType = type;
            });
            if (widget.onGoalTypeChanged != null) {
              widget.onGoalTypeChanged!(type);
            }
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(icon, size: 30, color: AppColors.darkerGrey),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: appFonts['Paragraph'],
                        color: AppColors.darkerGrey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: appFonts['Detail'],
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
                if (isSelected) ...[
                  const Spacer(),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.blue,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Gets the appropriate label text based on goal type and mode.
  ///
  /// @return A string representing the current goal unit (words, days, etc.)
  String _getLabelText() {
    final localizations = AppLocalizations.of(context)!;
    
    if (widget.isDaily) {
      switch (_goalType) {
        case GoalType.learn: return localizations.wordsPerDay;
        case GoalType.daily: return localizations.oneDailySession;
        case GoalType.time: return localizations.minutesPerDay;
      }
    } else {
      switch (_goalType) {
        case GoalType.learn: return localizations.totalWords;
        case GoalType.daily: return localizations.totalDays;
        case GoalType.time: return localizations.totalHours;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    
    // Configure based on mode
    final String labelText = _getLabelText();
    final int maxDigits = widget.isDaily ? 3 : 5;
    final double textFieldWidth = widget.isDaily ? 70 : 110;
    
    // Special case: For "daily" goal type in isDaily mode, we don't need a text field
    final bool hideTextField = _goalType == GoalType.daily && widget.isDaily;
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        fixedSize: Size(p.createCourseButtonWidth(), p.createCourseButtonHeight()),
        backgroundColor: Colors.white,
        overlayColor: Colors.transparent
      ),
      onPressed: () => _showGoalTypeSelector(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Only show text field if not hidden
          if (!hideTextField) ...[
            // Text field for number input
            SizedBox(
              width: textFieldWidth,
              height: 40,
              child: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    selectionColor: widget.isDaily ? AppColors.lightYellow : AppColors.lightBlue,
                    cursorColor: widget.isDaily ? AppColors.yellow : AppColors.blue,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: maxDigits,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    border: InputBorder.none,
                    counterText: "", // Hide character counter
                    isCollapsed: true,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: appFonts['Paragraph'],
                    color: AppColors.darkGrey,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(maxDigits),
                  ],
                  onChanged: (value) {
                    if (value.isEmpty) return;
                    final intValue = int.tryParse(value) ?? widget.initialValue;
                    widget.onValueChanged(intValue);
                  },
                  onTap: () {
                    // TextField will handle its own focus
                  },
                ),
              ),
            ),
            
            // Vertical divider
            Container(
              height: 30,
              width: 1,
              color: AppColors.darkerGrey.withAlpha(128),
            ),
            
            SizedBox(width: p.standardPadding()),
          ],
          
          // Goal type label
          Text(
            labelText,
            style: TextStyle(
              fontSize: 20, 
              fontFamily: appFonts['Paragraph'], 
              color: AppColors.black
            ),
          ),
          
          const Spacer(),
          
          // Moved arrow icon to the right side
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.black),
        ],
      ),
    );
  }
}