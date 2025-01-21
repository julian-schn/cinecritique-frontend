import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final String posterUrl;
  final String title;
  final String imdbId;
  final VoidCallback onTap;

  const MovieCard({
    Key? key,
    required this.posterUrl,
    required this.title,
    required this.imdbId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Ändert den Mauszeiger auf "Hand" beim Hover
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 250,
          height: 250,
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Image.network(
                  posterUrl,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              Container(
                height: 4,
                color: Colors.redAccent,
                margin: const EdgeInsets.only(bottom: 10.0),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
