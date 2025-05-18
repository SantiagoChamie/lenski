import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/data/archive_repository.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/models/archived_book_model.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/proportions.dart';

/// A screen that displays archived books for a specific course.
///
/// This component shows a grid of archived books sorted by category and subcategory.
/// Users can view and manage their archived books, which are books that have been
/// finished and removed from the regular library.
class ArchiveScreen extends StatefulWidget {
  /// The course whose archived books will be displayed
  final Course course;

  /// Creates an ArchiveScreen widget.
  /// 
  /// [course] is the course whose archived books will be displayed.
  const ArchiveScreen({super.key, required this.course});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final bookWidth = 120.0;
  final ArchiveRepository _archiveRepository = ArchiveRepository();
  List<ArchivedBook> _books = [];
  bool _isLoading = true;
  
  // Add focus node for keyboard events
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadBooks();
    
    // Request focus when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose(); // Dispose the focus node
    super.dispose();
  }

  /// Loads archived books for the current course.
  ///
  /// Fetches the list of archived books from the repository and updates the state.
  Future<void> _loadBooks() async {
    try {
      final books = await _archiveRepository.getArchivedBooks(widget.course.code);
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

  /// Builds a tile representing an archived book.
  ///
  /// Creates a book tile with cover image, title and tap handling for editing.
  /// [book] is the archived book data to display.
  Widget _buildBookTile(ArchivedBook book) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<dynamic>(
          context: context,
          builder: (context) => EditArchivedBookOverlay(
            book: book,
            onSave: (updatedBook) async {
              await _archiveRepository.updateArchivedBook(updatedBook);
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
      child: Container(
        width: bookWidth,
        margin: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: bookWidth * 4 / 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: book.imageUrl == null ? AppColors.lightBlue : null,
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
            const SizedBox(height: 8),
            SizedBox(
              height: 40, // Fixed height for two lines of text
              width: bookWidth,
              child: Text(
                book.name,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: appFonts['Detail'],
                  color: AppColors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the content of the archive screen.
  ///
  /// Shows either a message when the archive is empty or a grid of books
  /// organized by category and subcategory.
  /// [books] is the list of archived books to display.
  Widget _buildArchiveContent(List<ArchivedBook> books) {
    final localizations = AppLocalizations.of(context)!;
    
    if (books.isEmpty) {
      return Center(
        child: Text(
          localizations.noArchivedBooks,
          style: TextStyle(
            fontSize: 18,
            fontFamily: appFonts['Paragraph'],
            color: AppColors.darkGrey,
          ),
        ),
      );
    }

    final p = Proportions(context);
    const bookWidth = 136.0;
    final availableWidth = p.createCourseWidth() - 160;
    final booksPerRow = (availableWidth / bookWidth).floor();

    // Group books by category first
    final booksByCategory = <String, List<ArchivedBook>>{};
    
    for (var book in books) {
      final category = book.category.trim().isEmpty ? localizations.notCategorized : book.category;
      if (!booksByCategory.containsKey(category)) {
        booksByCategory[category] = [];
      }
      booksByCategory[category]!.add(book);
    }

    // Sort categories
    final orderedCategories = booksByCategory.keys.toList()
      ..sort((a, b) {
        if (a == localizations.notCategorized) return -1;
        if (b == localizations.notCategorized) return 1;
        return a.compareTo(b);
      });

    return SingleChildScrollView(
      child: Column(
        children: orderedCategories.map((category) {
          var categoryBooks = booksByCategory[category]!;

          // First sort all books by date
          categoryBooks.sort((a, b) => a.finishedDate.compareTo(b.finishedDate));

          // Create a map to store the position of the earliest book for each subcategory
          final subcategoryPositions = <String, int>{};
          final orderedBooks = <ArchivedBook>[];
          final pendingSubcategoryBooks = <String, List<ArchivedBook>>{};

          // Process books in chronological order
          for (var book in categoryBooks) {
            if (book.subcategory == null) {
              // Add books without subcategory directly to the result
              orderedBooks.add(book);
            } else {
              // For books with subcategory, track their position and group them
              if (!subcategoryPositions.containsKey(book.subcategory)) {
                // This is the first book of this subcategory - mark its position
                subcategoryPositions[book.subcategory!] = orderedBooks.length;
                pendingSubcategoryBooks[book.subcategory!] = [];
              }
              pendingSubcategoryBooks[book.subcategory!]!.add(book);
            }
          }

          // Insert subcategory groups at their correct positions
          subcategoryPositions.forEach((subcategory, position) {
            final subcategoryBooks = pendingSubcategoryBooks[subcategory]!;
            // Sort books within the subcategory by date
            subcategoryBooks.sort((a, b) => a.finishedDate.compareTo(b.finishedDate));
            // Insert the entire subcategory group at the position of its earliest book
            orderedBooks.insertAll(position, subcategoryBooks);
          });

          // Calculate rows
          final rowCount = (orderedBooks.length / booksPerRow).ceil();

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
                        fontFamily: appFonts['Subtitle'],
                        color: AppColors.darkerGrey,
                      ),
                    ),
                    const Divider(
                      color: Color(0xFFE0E0E0), // Keep original color
                      thickness: 1,
                      height: 16,
                    ),
                  ],
                ),
              ),
              ...List.generate(rowCount, (rowIndex) {
                final startIndex = rowIndex * booksPerRow;
                final endIndex = (startIndex + booksPerRow).clamp(0, orderedBooks.length);
                final rowBooks = orderedBooks.sublist(startIndex, endIndex);
                final emptySpaces = booksPerRow - rowBooks.length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...rowBooks.map((book) => _buildBookTile(book)),
                      ...List.generate(
                        emptySpaces,
                        (_) => Container(width: bookWidth),
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
    final localizations = AppLocalizations.of(context)!;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (KeyEvent event) {
        // Only process KeyDownEvent
        if (event is KeyDownEvent) {
          // Check for Escape key
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(boxPadding),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26, // Keep original shadow color
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Text(
                        localizations.archiveTitle,
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: appFonts['Title'],
                          color: AppColors.black,
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
      ),
    );
  }
}

/// A dialog for editing an archived book's details.
///
/// Allows users to modify the book's name, image URL, category, and subcategory.
/// Also provides an option to delete the book from the archive.
class EditArchivedBookOverlay extends StatefulWidget {
  /// The book to be edited
  final ArchivedBook book;
  
  /// Callback function when the book is saved
  final Function(ArchivedBook) onSave;

  /// Creates an EditArchivedBookOverlay widget.
  /// 
  /// [book] is the archived book to be edited.
  /// [onSave] is the callback function to be called when the book is saved.
  const EditArchivedBookOverlay({
    super.key,
    required this.book,
    required this.onSave,
  });

  @override
  State<EditArchivedBookOverlay> createState() => _EditArchivedBookOverlayState();
}

class _EditArchivedBookOverlayState extends State<EditArchivedBookOverlay> {
  final ArchiveRepository _archiveRepository = ArchiveRepository();

  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  late TextEditingController _categoryController;
  late TextEditingController _subcategoryController; // New controller

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.book.name);
    _imageUrlController = TextEditingController(text: widget.book.imageUrl ?? '');
    _categoryController = TextEditingController(text: widget.book.category);
    _subcategoryController = TextEditingController(text: widget.book.subcategory ?? ''); // Initialize subcategory
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose(); // Dispose subcategory
    super.dispose();
  }

  /// Shows a confirmation dialog before deleting a book.
  ///
  /// If the user confirms deletion, removes the book from the archive.
  Future<void> _deleteBook() async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localizations.deleteArchivedBookTitle,
          style: TextStyle(
            fontFamily: appFonts['Subtitle'],
            fontSize: 24,
          ),
        ),
        content: Text(
          localizations.deleteArchivedBookConfirmation,
          style: TextStyle(
            fontFamily: appFonts['Paragraph'],
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              localizations.cancel,
              style: TextStyle(
                fontFamily: appFonts['Detail'],
                fontSize: 14,
                color: AppColors.blue,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              textStyle: TextStyle(
                fontFamily: appFonts['Detail'],
                fontSize: 14,
              ),
            ),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _archiveRepository.deleteArchivedBook(widget.book.id!);
      if (mounted) {
        Navigator.pop(context, 'deleted'); // Special return value to indicate deletion
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 400,
        
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: AppColors.lightBlue,
              cursorColor: Colors.black54, // Keep original cursor color
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.editArchivedBookTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: appFonts['Subtitle'],
                    ),
                  ),
                  IconButton(
                    onPressed: _deleteBook,
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.error,
                    tooltip: localizations.deleteArchivedBookTooltip,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: localizations.nameLabel,
                  labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: AppColors.darkGrey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.blue, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: localizations.imageUrlLabel,
                  labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: AppColors.darkGrey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.blue, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: localizations.categoryLabel,
                  labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: AppColors.darkGrey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.blue, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _subcategoryController,
                decoration: InputDecoration(
                  labelText: localizations.subcategoryLabel,
                  labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: AppColors.darkGrey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.blue, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      localizations.cancel,
                      style: TextStyle(
                        fontFamily: appFonts['Detail'],
                        fontSize: 14,
                        color: AppColors.error,
                      ),
                    ),
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
                        subcategory: _subcategoryController.text.trim().isEmpty
                            ? null
                            : _subcategoryController.text.trim().toLowerCase(),
                        finishedDate: DateTime.fromMillisecondsSinceEpoch(
                          widget.book.finishedDate * 86400000,
                        ),
                      );
                      widget.onSave(updatedBook);
                      Navigator.pop(context, updatedBook); // Return the updated book
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Keep original color
                    ),
                    child: Text(
                      localizations.save,
                      style: TextStyle(
                        fontFamily: appFonts['Detail'],
                        fontSize: 14,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}