import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/models/book_model.dart';
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/proportions.dart';

/// A screen for editing an existing book in a course.
///
/// This screen allows users to:
/// - Change the book's title
/// - Update the book cover image URL
/// - View book statistics like language and reading progress
/// - Archive a completed book
/// - Delete a book permanently
class EditBookScreen extends StatefulWidget {
  /// The book to be edited
  final Book book;
  
  /// Callback function to return to the previous screen
  final VoidCallback onBackPressed;

  /// Creates an EditBookScreen widget.
  /// 
  /// [book] is the book to be edited.
  /// [onBackPressed] is the callback function to be called when the back button is pressed.
  const EditBookScreen({
    super.key,
    required this.book,
    required this.onBackPressed,
  });

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  late TextEditingController _titleController;
  late TextEditingController _imageUrlController;
  final BookRepository _bookRepository = BookRepository();
  
  // Add focus node for keyboard events
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.name);
    _imageUrlController = TextEditingController(text: widget.book.imageUrl ?? '');
    
    // Request focus when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _keyboardFocusNode.dispose(); // Dispose the focus node
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final updatedBook = widget.book.copyWith(
      name: _titleController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
    );
    
    await _bookRepository.updateBook(updatedBook);
    if (mounted) {
      widget.onBackPressed();
    }
  }

  Future<void> _deleteBook(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            localizations.deleteBookTitle,
            style: TextStyle(
              fontSize: 24,
              fontFamily: appFonts['Subtitle'],
            ),
          ),
          content: Text(
            localizations.deleteBookConfirmation,
            style: TextStyle(
              fontSize: 16,
              fontFamily: appFonts['Paragraph'],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: appFonts['Detail'],
                ),
              ),
              child: Text(localizations.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: appFonts['Detail'],
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _bookRepository.deleteBook(widget.book.id!);
      if (mounted) {
        widget.onBackPressed();
      }
    }
  }

  /// Shows a confirmation dialog for archiving the book.
  Future<void> _showArchiveConfirmation() async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localizations.archiveBookTitle,
          style: TextStyle(
            fontSize: 24, 
            fontFamily: appFonts['Subtitle'],
          ),
        ),
        content: Text(
          localizations.archiveBookConfirmation,
          style: TextStyle(
            fontSize: 16, 
            fontFamily: appFonts['Paragraph'],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              localizations.cancel,
              style: TextStyle(
                color: AppColors.error, 
                fontSize: 14, 
                fontFamily: appFonts['Detail']
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.blue,
              textStyle: TextStyle(
                fontSize: 14, 
                fontFamily: appFonts['Detail']
              ),
            ),
            child: Text(localizations.archive),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final bookRepository = BookRepository();
      await bookRepository.archiveBook(widget.book);
      if (mounted) {
        Navigator.pop(context); // Close book screen after archiving
      }
    }
  }

  Widget _buildDetailsSection() {
    final localizations = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      child: Theme(
        data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: AppColors.lightBlue,
              cursorColor: Colors.black54, // Keep as is for cursor color
            ),
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: localizations.bookTitleLabel,
                labelStyle: TextStyle(
                  fontFamily: appFonts['Detail'],
                  fontSize: 16,
                  color: AppColors.darkGrey,
                ),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.blue, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: localizations.imageUrlLabel,
                hintText: localizations.enterImageUrlHint,
                labelStyle: TextStyle(
                  fontFamily: appFonts['Detail'],
                  fontSize: 16,
                  color: AppColors.darkGrey,
                ),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.blue, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailItem(localizations.languageLabel, widget.book.language),
            _buildDetailItem(
              localizations.currentProgressLabel, 
              '${widget.book.currentLine} / ${widget.book.totalLines} ${localizations.lines} '
              '(${(widget.book.currentLine / widget.book.totalLines * 100).toInt()}%)'
            ),
            if (widget.book.finished) // Only show archive button if book is finished
              SizedBox(
                child: TextButton(
                  onPressed: () async {
                    await _showArchiveConfirmation();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    localizations.archiveBook,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: appFonts['Detail'],
                    ),
                  ),
                ),
              ),
            SizedBox(
              child: TextButton(
                onPressed: () => _deleteBook(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  localizations.deleteBook,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: appFonts['Detail'],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey,
              fontFamily: appFonts['Subtitle'],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontFamily: appFonts['Detail'],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final localizations = AppLocalizations.of(context)!;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (KeyEvent event) {
        // Only process KeyDownEvent
        if (event is KeyDownEvent) {
          // Check for Escape key
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onBackPressed();
          }
          // Check for Enter key
          else if (event.logicalKey == LogicalKeyboardKey.enter) {
            _saveChanges();
          }
          // Check for Delete key
          else if (event.logicalKey == LogicalKeyboardKey.delete || event.logicalKey == LogicalKeyboardKey.keyD) {
            _deleteBook(context);
          }
          // Check for 'A' key
          else if (event.logicalKey == LogicalKeyboardKey.keyA) {
            if(widget.book.finished) {
              _showArchiveConfirmation();
            }
          }
        }
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: p.standardPadding()),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: p.createCourseWidth(),
                maxHeight: p.createCourseHeight(),
              ),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12, // Keep as is for shadow
                    blurRadius: 2,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(p.standardPadding() * 2),
                    child: Column(
                      children: [
                        Text(
                          localizations.editBookTitle,
                          style: TextStyle(fontSize: 24, fontFamily: appFonts['Title']),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 300,
                                height: double.infinity,
                                padding: const EdgeInsets.only(bottom: 24), // Space for the button
                                child: _buildImageSection(),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                child: _buildDetailsSection(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: p.sidebarButtonWidth(),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              localizations.saveChangesButton,
                              style: TextStyle(
                                fontFamily: appFonts['Detail'],
                                fontSize: 30,
                                color: Colors.white, // Keep as is for contrast
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onBackPressed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightYellow,
        borderRadius: BorderRadius.circular(10),
        image: widget.book.imageUrl != null ? DecorationImage(
          image: NetworkImage(widget.book.imageUrl!),
          fit: BoxFit.cover,
        ) : null,
      ),
      child: widget.book.imageUrl == null ? const Center(
        child: Icon(
          Icons.book_outlined,
          size: 120,
          color: Colors.white, // Keep as is for visibility
        ),
      ) : null,
    );
  }
}