class LTextSelectionController {
  String selectedText = '';
  void Function()? onSelectionChanged;

  void updateSelection(String text) {
    selectedText = text;
    onSelectionChanged?.call();
  }

  void clearSelection() {
    selectedText = '';
    onSelectionChanged?.call();
  }
}