import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String content;

  const ResultCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.remove_red_eye,
              size: 40,
              color:Color(0xFF5F8F58)
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (content.isNotEmpty)
                ...content
                  .split(', ')
                  .map((label) => Text(
                        label,
                        style: TextStyle(
                        fontSize: 16,
                        color: Colors.green[900],
                        ),
                      ))
                  .toList()
              else
                Text(
                  'No relevant diseases or pests detected.',
                  style: TextStyle(fontSize: 16, color: Colors.green[900]),
                ),
          ],
        ),
      ),
    );
  }
}