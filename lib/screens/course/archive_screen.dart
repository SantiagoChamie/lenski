import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/models/archived_book_model.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/book_repository.dart';

class ArchiveScreen extends StatefulWidget {
  final Course course;

  const ArchiveScreen({super.key, required this.course});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final BookRepository _bookRepository = BookRepository();

  Widget _buildBookTile(ArchivedBook book) {
    return Tooltip(
      message: 'Language: ${book.language}\nCategory: ${book.category}',
      child: Container(
        width: 120,
        margin: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF2C73DE),
                  width: 2,
                ),
                image: book.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(book.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: book.imageUrl == null
                  ? const Center(
                      child: Icon(
                        Icons.book,
                        size: 48,
                        color: Color(0xFF2C73DE),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              book.name,
              style: const TextStyle(
                fontFamily: 'Varela Round',
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
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

    // Sort books by category
    final booksByCategory = <String, List<ArchivedBook>>{};
    for (var book in books) {
      if (!booksByCategory.containsKey(book.category)) {
        booksByCategory[book.category] = [];
      }
      booksByCategory[book.category]!.add(book);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: booksByCategory.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  entry.key.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Unbounded",
                    color: Color(0xFF2C73DE),
                  ),
                ),
              ),
              SizedBox(
                height: 220, // Fixed height for book rows
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: entry.value.map((book) => _buildBookTile(book)).toList(),
                ),
              ),
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
    const iconSize = 80.0;

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
              child: FutureBuilder<List<ArchivedBook>>(
                future: _bookRepository.getArchivedBooks(widget.course.code),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  return _buildArchiveContent(snapshot.data ?? []);
                },
              ),
            ),
          ),
        ),
        Positioned(
          top: boxPadding - iconSize / 3,
          left: boxPadding - iconSize / 3,
          child: FlagIcon(
            size: iconSize,
            borderWidth: 5.0,
            borderColor: const Color(0xFFD9D0DB),
            imageUrl: widget.course.imageUrl,
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