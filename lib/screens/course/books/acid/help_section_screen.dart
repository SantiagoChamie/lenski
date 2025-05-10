import 'package:flutter/material.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/utils/proportions.dart';

class HelpSectionScreen extends StatelessWidget {
  const HelpSectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: p.standardPadding()*2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildHelpColumn(
                  'Real-Life Interactions',
                  Icons.people_outline,
                  [
                    'Video transcripts',
                    'Conversation logs',
                    'Interview transcripts',
                    'Podcasts transcripts',
                    'Daily dialogues',
                    'Travel phrases'
                  ],
                  'Great for learning everyday language and common expressions people use in real situations.'
                ),
              ),
              SizedBox(width: p.standardPadding()),
              Expanded(
                child: _buildHelpColumn(
                  'Entertainment',
                  Icons.movie_outlined,
                  [
                    'Song lyrics',
                    'Books and stories',
                    'Movie scripts',
                    'Movie subtitles',
                    'TV show scripts',
                    'Plays and dialogues'
                  ],
                  'Contains various difficulty levels from simple songs to complex narratives. Great for cultural context.'
                ),
              ),
              SizedBox(width: p.standardPadding()),
              Expanded(
                child: _buildHelpColumn(
                  'Articles & Academic',
                  Icons.article_outlined,
                  [
                    'Wikipedia articles',
                    'News articles',
                    'Scientific papers',
                    'Blog posts',
                    'Educational materials',
                    'Specialized vocabulary'
                  ],
                  'Perfect for learning formal language and specific vocabulary in different fields of interest.'
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFF2C73DE)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Start with content that matches your interests! Learning is more effective when you enjoy what you\'re reading.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                Icon(icon, color: const Color(0xFF2C73DE), size: 24),
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
                  const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey[700], fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}