// genre_card.dart
import 'package:flutter/material.dart';

class GenreCard extends StatelessWidget {
  final String genre;
  final VoidCallback? onTap;

  const GenreCard({
    super.key,
    required this.genre,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
     return MouseRegion(
      cursor: SystemMouseCursors.click, // Ändert den Mauszeiger auf "Hand" beim Hover
    child:  GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            genre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
     );
  }
}