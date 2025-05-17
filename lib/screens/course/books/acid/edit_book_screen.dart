import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenski/models/book_model.dart';
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/utils/proportions.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;
  final VoidCallback onBackPressed;

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
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Book',
            style: TextStyle(
              fontSize: 24,
              fontFamily: appFonts['Subtitle']!,
            ),
          ),
          content: Text('Are you sure you want to delete this book?',
            style: TextStyle(
              fontSize: 16,
              fontFamily: appFonts['Paragraph']!,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2C73DE),
                textStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: appFonts['Detail']!,
                ),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: appFonts['Detail']!,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Archive Book',
          style: TextStyle(
            fontSize: 24, 
            fontFamily: appFonts['Subtitle'],
          ),
        ),
        content: Text('Are you sure you want to archive this book? Archiving will remove all of this book\'s contents.',
          style: TextStyle(
            fontSize: 16, 
            fontFamily: appFonts['Paragraph'],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
              style: TextStyle(color: Colors.red, fontSize: 14, fontFamily: appFonts['Detail']),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2C73DE),
              textStyle: TextStyle(fontSize: 14, fontFamily: appFonts['Detail']),
            ),
            child: const Text('Archive'),
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
    return SingleChildScrollView(
      child: Theme(
        data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: Color(0xFF71BDE0),
              cursorColor: Colors.black54,   
            ),
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Book Title',
                labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2C73DE), width: 2.0),
                  ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'Image URL',
                hintText: 'Enter image URL',
                labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2C73DE), width: 2.0),
                  ),
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailItem('Language', widget.book.language),
            _buildDetailItem('Current Progress', 
              '${widget.book.currentLine} / ${widget.book.totalLines} lines ' 
              '(${(widget.book.currentLine / widget.book.totalLines * 100).toInt()}%)'
            ),
            if (widget.book.finished) // Only show archive button if book is finished
              SizedBox(
                child: TextButton(
                  onPressed: () async {
                    await _showArchiveConfirmation();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2C73DE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Archive book',
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
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Delete book',
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
              color: Colors.grey,
              fontFamily: appFonts['Subtitle']!,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontFamily: appFonts['Detail']!,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

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
                color: const Color(0xFFF5F0F6),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
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
                          'Edit Book',
                          style: TextStyle(fontSize: 24, fontFamily: appFonts['Title']!),
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
                              backgroundColor: const Color(0xFF2C73DE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Save Changes",
                              style: TextStyle(
                                fontFamily: appFonts['Detail']!,
                                fontSize: 30,
                                color: Colors.white,
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
        color: const Color(0xFFFFD38D),
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
          color: Colors.white,
        ),
      ) : null,
    );
  }
}