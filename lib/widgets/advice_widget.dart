import 'package:flutter/material.dart';

class AdviceWidget extends StatelessWidget {
  final String advice;

  const AdviceWidget({Key? key, required this.advice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*'); // Matches text between **
    final List<Widget> lines = [];

    // Split the advice into lines
    final adviceLines = advice.split('\n');

    for (final line in adviceLines) {
      final trimmedLine = line.trim();

      if (trimmedLine.startsWith('##')) {
        // Handle lines that start with ## (custom header style)
        final headerText = trimmedLine.substring(2).trim(); // Remove the '##' and trim whitespace
        lines.add(
          Text(
            headerText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5F8F58)
            ),
          ),
        );
      } 
      else if(trimmedLine.startsWith('**')) {
        // Handle lines that start with ** (fully bold lines)
        final List<TextSpan> spans = _parseBoldText(trimmedLine, boldPattern);

        lines.add(
          RichText(
            text: TextSpan(children: spans),
          ),
        );
      } else if (trimmedLine.startsWith('*')) {
        // Handle bullet points
        final textWithoutBullet = trimmedLine.substring(1).trim(); // Remove the '*' and trim whitespace
        final List<TextSpan> bulletSpans = _parseBoldText(textWithoutBullet, boldPattern);

        lines.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '• ', // Bullet point
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(children: bulletSpans),
                ),
              ),
            ],
          ),
        );
      } else {
        // Handle regular lines (including mixed formatting)
        final List<TextSpan> spans = _parseBoldText(trimmedLine, boldPattern);

        lines.add(
          RichText(
            text: TextSpan(children: spans),
          ),
        );
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
              Text(
                'Expert Advice',
                style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                ),
              ),
              SizedBox(width: 4), // Add some spacing between the icon and text
              Icon(
                Icons.lightbulb,
                size: 18,
                color: Color(0xFFF9B71C),
              ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Follow these recommendations to manage the detected issues effectively.',
              style: TextStyle(fontSize: 14, color: Colors.green[900], fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            ...lines
          ]
        ),
      ),
    );
  }

  List<TextSpan> _parseBoldText(String text, RegExp boldPattern) {
    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    // Find all matches of the bold pattern
    for (final match in boldPattern.allMatches(text)) {
      // Add non-bold text before the match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ));
      }

      // Add bold text
      spans.add(TextSpan(
        text: match.group(1), // Extract the text inside **
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ));

      lastMatchEnd = match.end;
    }

    // Add remaining non-bold text after the last match
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ));
    }

    return spans;
  }
}