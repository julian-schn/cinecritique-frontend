import 'package:flutter/material.dart';

class FavoriteToggle extends StatefulWidget {
  const FavoriteToggle({super.key, this.iconSize = 40});

  final double iconSize; // Die Größe des gesamten Icons

  @override
  _FavoriteToggleState createState() => _FavoriteToggleState();
}

class _FavoriteToggleState extends State<FavoriteToggle> {
  bool isFavorited = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFavorited = !isFavorited;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
            size: widget.iconSize, // Skaliert das gesamte Herz-Icon
          ),
          if (!isFavorited)
            Positioned(
              bottom: 11 * (widget.iconSize / 40), // Skaliert die Position des Plus-Icons
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 18 * (widget.iconSize / 40), // Skaliert das Plus-Icon
              ),
            ),
          if (isFavorited)
            Positioned(
              bottom: 11 * (widget.iconSize / 40), // Skaliert die Position des Häkchen-Icons
              child: Icon(
                Icons.check,
                color: Color(0xFF121212),
                size: 18 * (widget.iconSize / 40), // Skaliert das Häkchen-Icon
              ),
            ),
        ],
      ),
    );
  }
}
