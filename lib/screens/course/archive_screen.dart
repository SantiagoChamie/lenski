import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/models/archived_book_model.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/book_repository.dart';

class ArchiveScreen extends StatefulWidget {
  final Course course;

  const ArchiveScreen({super.key, required this.course});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final bookWidth = 120.0;
  final BookRepository _bookRepository = BookRepository();
  List<ArchivedBook> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bookRepository.getArchivedBooks(widget.course.code);
      if (mounted) {
        setState(() {
          _books = books;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _books = [];
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBookTile(ArchivedBook book) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<dynamic>(
          context: context,
          builder: (context) => EditArchivedBookOverlay(
            book: book,
            onSave: (updatedBook) async {
              await _bookRepository.updateArchivedBook(updatedBook);
              if (mounted) {
                setState(() {
                  final index = _books.indexWhere((b) => b.id == updatedBook.id);
                  if (index != -1) {
                    _books[index] = updatedBook;
                  }
                });
              }
            },
          ),
        );

        if (mounted && result == 'deleted') {
          setState(() {
            _books.removeWhere((b) => b.id == book.id);
          });
        }
      },
      child: Tooltip(
        message: book.name,
        child: Container(
          width: bookWidth,
          margin: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: bookWidth * 4 / 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: book.imageUrl == null ? const Color(0xFF71BDE0) : null,
                  // Only add border if there's an image
                  border: book.imageUrl != null ? null : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (book.imageUrl != null && book.imageUrl!.isNotEmpty)
                      ? Image.network(
                          book.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.white,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.book,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchiveContent(List<ArchivedBook> books) {
    if (books.isEmpty) {
      return const Center(
        child: Text(
          'Finish books to add them to your archive',
          style: TextStyle(
            fontSize: 18,
            fontFamily: "Varela Round",
            color: Color(0xFF757575),
          ),
        ),
      );
    }

    final p = Proportions(context);
    // Calculate how many books can fit in a row
    // Book width is 120 + 16 (margins)
    const bookWidth = 136.0;
    final availableWidth = p.createCourseWidth() - 160; // Account for padding
    final booksPerRow = (availableWidth / bookWidth).floor();

    // Sort and organize books as before
    final booksByCategory = <String, List<ArchivedBook>>{};
    for (var book in books) {
      final category = book.category.trim().isEmpty ? 'Not Categorized' : book.category;
      if (!booksByCategory.containsKey(category)) {
        booksByCategory[category] = [];
      }
      booksByCategory[category]!.add(book);
    }

    booksByCategory.forEach((category, books) {
      books.sort((a, b) => a.finishedDate.compareTo(b.finishedDate));
    });

    final orderedCategories = booksByCategory.keys.toList()
      ..sort((a, b) {
        if (a == 'Not Categorized') return -1;
        if (b == 'Not Categorized') return 1;
        return a.compareTo(b);
      });

    return SingleChildScrollView(
      child: Column(
        children: orderedCategories.map((category) {
          final categoryBooks = booksByCategory[category]!;
          final rowCount = (categoryBooks.length / booksPerRow).ceil();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.substring(0, 1).toUpperCase() +
                          category.substring(1).toLowerCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Telex",
                        color: Colors.grey[800],
                      ),
                    ),
                    const Divider(
                      color: Color(0xFFE0E0E0),
                      thickness: 1,
                      height: 16,
                    ),
                  ],
                ),
              ),
              ...List.generate(rowCount, (rowIndex) {
                final startIndex = rowIndex * booksPerRow;
                final endIndex = (startIndex + booksPerRow).clamp(0, categoryBooks.length);
                final rowBooks = categoryBooks.sublist(startIndex, endIndex);

                // Calculate how many empty spaces we need
                final emptySpaces = booksPerRow - rowBooks.length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...rowBooks.map((book) => _buildBookTile(book)),
                      // Add empty containers to fill the row
                      ...List.generate(
                        emptySpaces,
                        (_) => Container(
                          width: bookWidth,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final boxPadding = p.standardPadding() * 4;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(boxPadding),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0F6),
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Text(
                      'The Archive',
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Unbounded',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildArchiveContent(_books),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: boxPadding + 10,
          right: boxPadding + 10,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ),
      ],
    );
  }
}

class EditArchivedBookOverlay extends StatefulWidget {
  final ArchivedBook book;
  final Function(ArchivedBook) onSave;

  const EditArchivedBookOverlay({
    super.key,
    required this.book,
    required this.onSave,
  });

  @override
  State<EditArchivedBookOverlay> createState() => _EditArchivedBookOverlayState();
}

class _EditArchivedBookOverlayState extends State<EditArchivedBookOverlay> {
  final BookRepository _bookRepository = BookRepository();

  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.book.name);
    _imageUrlController = TextEditingController(text: widget.book.imageUrl ?? '');
    _categoryController = TextEditingController(text: widget.book.category);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _deleteBook() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book from your archive?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _bookRepository.deleteArchivedBook(widget.book.id!);
      if (mounted) {
        Navigator.pop(context, 'deleted'); // Special return value to indicate deletion
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Book',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Telex',
                  ),
                ),
                IconButton(
                  onPressed: _deleteBook,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Delete book',
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final imageUrl = _imageUrlController.text.trim();
                    final updatedBook = ArchivedBook(
                      id: widget.book.id,
                      name: _nameController.text.trim(),
                      language: widget.book.language,
                      imageUrl: imageUrl.isEmpty ? null : imageUrl,
                      category: _categoryController.text.trim().toLowerCase(),
                      finishedDate: DateTime.fromMillisecondsSinceEpoch(
                        widget.book.finishedDate * 86400000,
                      ),
                    );
                    widget.onSave(updatedBook);
                    Navigator.pop(context, updatedBook); // Return the updated book
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}