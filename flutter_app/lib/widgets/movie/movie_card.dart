import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final String posterUrl;
  final String title;
  final String imdbId;
  final VoidCallback onTap;
  final double cardWidth;
  final double cardHeight;

  const MovieCard({
    Key? key,
    required this.posterUrl,
    required this.title,
    required this.imdbId,
    required this.onTap,
    this.cardWidth = 250,
    this.cardHeight = 250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
   
    final double posterHeight = cardHeight * 0.75;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: cardWidth,
          height: cardHeight,
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
                  height: posterHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              Container(
                height: cardHeight - posterHeight,
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      color: Colors.redAccent,
                      margin: const EdgeInsets.only(bottom: 4.0),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: cardHeight * 0.07, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
