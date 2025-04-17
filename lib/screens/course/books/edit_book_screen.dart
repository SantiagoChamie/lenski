import 'package:flutter/material.dart';
import 'package:lenski/models/book_model.dart';
import 'package:lenski/data/book_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.name);
    _imageUrlController = TextEditingController(text: widget.book.imageUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
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
          title: const Text('Delete Book'),
          content: const Text('Are you sure you want to delete this book?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 171, 163, 172),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
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

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Book Title',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2C73DE), width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            hintText: 'Enter image URL',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2C73DE), width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildDetailItem('Language', widget.book.language),
        _buildDetailItem('Total Lines', widget.book.totalLines.toString()),
        _buildDetailItem('Current Progress', 
          '${widget.book.currentLine} / ${widget.book.totalLines} lines ' 
          '(${(widget.book.currentLine / widget.book.totalLines * 100).toInt()}%)'
        ),
        const Spacer(),
        SizedBox(
          child: TextButton(
            onPressed: () => _deleteBook(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Delete book',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Varela Round',
              ),
            ),
          ),
        ),
        const SizedBox(height: 20)
      ],
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
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: "Telex",
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: "Varela Round",
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

    return Scaffold(
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
                      const Text(
                        'Edit Book',
                        style: TextStyle(fontSize: 24, fontFamily: "Unbounded"),
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
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontFamily: "Telex",
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
                  left: 10,
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