import 'package:flutter/material.dart';

class GenreCard extends StatelessWidget {
  final String genre;
  final VoidCallback? onTap;
  final double cardWidth;
  final double cardHeight;

  const GenreCard({
    super.key,
    required this.genre,
    this.onTap,
    this.cardWidth = 250,  // Standardbreite, falls keine spezifische Breite übergeben wird
    this.cardHeight = 140, // Standardhöhe
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Ändert den Mauszeiger auf "Hand" beim Hover
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: cardWidth,
          height: cardHeight,
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
              style: TextStyle(
                color: Colors.white,
                fontSize: cardHeight * 0.2, // Schriftgröße proportional zur Kartenhöhe
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
