import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/proportions.dart';

/// A widget that displays help content for different types of text sources.
///
/// This screen provides guidance about the types of content that can be added as books:
/// - Real-life interactions (conversations, dialogues, etc.)
/// - Entertainment sources (songs, books, movies, etc.)
/// - Academic content (articles, papers, etc.)
///
/// Each section includes examples and a description of benefits.
class HelpSectionScreen extends StatelessWidget {
  /// Creates a HelpSectionScreen widget.
  const HelpSectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final localizations = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: p.standardPadding()*2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildHelpColumn(
                  localizations.realLifeInteractionsTitle,
                  Icons.people_outline,
                  [
                    localizations.videoTranscripts,
                    localizations.conversationLogs,
                    localizations.interviewTranscripts,
                    localizations.podcastTranscripts,
                    localizations.dailyDialogues,
                    localizations.travelPhrases
                  ],
                  localizations.realLifeInteractionsDescription
                ),
              ),
              SizedBox(width: p.standardPadding()),
              Expanded(
                child: _buildHelpColumn(
                  localizations.entertainmentTitle,
                  Icons.movie_outlined,
                  [
                    localizations.songLyrics,
                    localizations.booksAndStories,
                    localizations.movieScripts,
                    localizations.movieSubtitles,
                    localizations.tvShowScripts,
                    localizations.playsAndDialogues
                  ],
                  localizations.entertainmentDescription
                ),
              ),
              SizedBox(width: p.standardPadding()),
              Expanded(
                child: _buildHelpColumn(
                  localizations.articlesAcademicTitle,
                  Icons.article_outlined,
                  [
                    localizations.wikipediaArticles,
                    localizations.newsArticles,
                    localizations.scientificPapers,
                    localizations.blogPosts,
                    localizations.educationalMaterials,
                    localizations.specializedVocabulary
                  ],
                  localizations.articlesAcademicDescription
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD), // Keep as is (light blue background)
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localizations.contentTip,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: appFonts['Paragraph'],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an individual help column with title, icon, list of items, and description.
  ///
  /// @param title The title of the help section
  /// @param icon The icon to display next to the title
  /// @param items A list of examples for this category
  /// @param description A description of the benefits of this content type
  Widget _buildHelpColumn(String title, IconData icon, List<String> items, String description) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    fontFamily: appFonts['Subtitle']
                  ),
                ),
              ],
            ),
            const Divider(),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold,
                    fontFamily: appFonts['Paragraph'],
                  )),
                  Expanded(
                    child: Text(
                      item, 
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: appFonts['Paragraph'],
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 13, 
                color: AppColors.darkGrey, 
                fontStyle: FontStyle.italic,
                fontFamily: appFonts['Paragraph'],
              ),
            ),
          ],
        ),
      ),
    );
  }
}