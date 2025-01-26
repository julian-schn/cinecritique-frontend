import 'package:flutter/material.dart';

class FavoriteToggle extends StatefulWidget {
  const FavoriteToggle({
    super.key,
    this.iconSize = 40,
    this.onTap, // Der Callback, der nach dem Klick ausgelöst wird
  });

  final double iconSize; // Die Größe des gesamten Icons
  final VoidCallback? onTap; // Der Callback, der nach dem Klick ausgelöst wird

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
          isFavorited = !isFavorited; // Favoritenstatus umschalten
        });

        if (widget.onTap != null) {
          widget.onTap!(); // Den Callback auslösen, wenn gesetzt
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
            size: widget.iconSize,
          ),
          if (!isFavorited)
            Positioned(
              bottom: 11 * (widget.iconSize / 40),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 18 * (widget.iconSize / 40),
              ),
            ),
          if (isFavorited)
            Positioned(
              bottom: 11 * (widget.iconSize / 40),
              child: Icon(
                Icons.check,
                color: Color(0xFF121212),
                size: 18 * (widget.iconSize / 40),
              ),
            ),
        ],
      ),
    );
  }
}
