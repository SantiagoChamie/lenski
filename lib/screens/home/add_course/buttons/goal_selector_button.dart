import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenski/utils/proportions.dart';

/// A button widget for selecting a word reading goal.
class GoalSelectorButton extends StatefulWidget {
  final Function(int) onValueChanged;
  final int initialValue;
  final bool isDaily; // New parameter to control button mode

  /// Creates a GoalSelectorButton widget.
  /// 
  /// [initialValue] is the initial number of words.
  /// [onValueChanged] is the callback function that is called when the goal value changes.
  /// [mode] determines if this is a daily goal ('daily') or total goal ('general').
  const GoalSelectorButton({
    super.key, 
    required this.onValueChanged,
    this.initialValue = 100,
    this.isDaily = true, // Default to daily mode
  });

  @override
  _GoalSelectorButtonState createState() => _GoalSelectorButtonState();
}

class _GoalSelectorButtonState extends State<GoalSelectorButton> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
    _focusNode = FocusNode();
    
    // Call the callback with initial value
    Future.microtask(() {
      widget.onValueChanged(widget.initialValue);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    
    // Configure based on mode
    final String labelText = widget.isDaily ? "words per day" : "total words";
    final int maxDigits = widget.isDaily ? 3 : 5;
    final double textFieldWidth = widget.isDaily ? 70 : 110; // Wider for general mode
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        fixedSize: Size(p.createCourseButtonWidth(), p.createCourseButtonHeight()),
        backgroundColor: Colors.white,
        overlayColor: Colors.transparent
      ),
      onPressed: () {
        // Focus on the text field when button is pressed
        _focusNode.requestFocus();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text field for number input
          SizedBox(
            width: textFieldWidth,
            height: 40,
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  selectionColor: widget.isDaily ? const Color(0xFFFFD38D) : const Color(0xFF71BDE0), // Light orange highlight
                  cursorColor: widget.isDaily ? const Color(0xFFEE9A1D) : const Color(0xFF2C73DE),    // Orange cursor
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
          Text(
            labelText,
            style: const TextStyle(fontSize: 20, fontFamily: "Varela Round", color: Colors.black),
          ),     
          const Spacer()     
        ],
      ),
    );
  }
}