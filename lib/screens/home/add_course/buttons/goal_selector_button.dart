import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenski/utils/proportions.dart';

/// Defines the available goal types for reading
enum GoalType {
  learn,  // Finding x new words
  daily,  // Study x days
  time    // Study for x hours
}

/// A button widget for selecting a word reading goal.
class GoalSelectorButton extends StatefulWidget {
  final Function(int) onValueChanged;
  final Function(GoalType)? onGoalTypeChanged;
  final int initialValue;
  final bool isDaily; // Controls if this is for daily goals or global goals
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
  late TextEditingController _controller;
  late FocusNode _focusNode;
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

  // Add this method to respond to widget property changes
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
  void _showGoalTypeSelector(BuildContext context) {
    final p = Proportions(context);
    
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
                    "Select Goal Type",
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: "Telex",
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildGoalTypeOption(
                        context, 
                        GoalType.learn, 
                        "Learn", 
                        "Track words learned",
                        Icons.psychology
                      ),
                      _buildGoalTypeOption(
                        context, 
                        GoalType.daily, 
                        "Daily", 
                        "Track study days",
                        Icons.calendar_today
                      ),
                      _buildGoalTypeOption(
                        context, 
                        GoalType.time, 
                        "Time", 
                        "Track study hours",
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
  
  Widget _buildGoalTypeOption(BuildContext context, GoalType type, String title, String subtitle, IconData icon) {
    final bool isSelected = type == _goalType;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isSelected ? const Color(0xFFF5F0F6) : Colors.transparent,
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
                Icon(icon, size: 30, color: Colors.grey[700]),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Varela Round",
                        color: Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (isSelected) ...[
                  const Spacer(),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2C73DE),
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

  String _getLabelText() {
    if (widget.isDaily) {
      switch (_goalType) {
        case GoalType.learn: return "words per day";
        case GoalType.daily: return "1 daily session";
        case GoalType.time: return "minutes per day";
      }
    } else {
      switch (_goalType) {
        case GoalType.learn: return "total words";
        case GoalType.daily: return "total days";
        case GoalType.time: return "total hours";
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
                    selectionColor: widget.isDaily ? const Color(0xFFFFD38D) : const Color(0xFF71BDE0),
                    cursorColor: widget.isDaily ? const Color(0xFFEE9A1D) : const Color(0xFF2C73DE),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Varela Round",
                    color: Colors.grey,
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
              color: Colors.grey.withAlpha(128),
            ),
            
            SizedBox(width: p.standardPadding()),
          ],
          
          // Goal type label
          Text(
            labelText,
            style: const TextStyle(fontSize: 20, fontFamily: "Varela Round", color: Colors.black),
          ),
          
          const Spacer(),
          
          // Moved arrow icon to the right side
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
        ],
      ),
    );
  }
}