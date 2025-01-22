import 'package:flutter/material.dart';

class FavoriteToggle extends StatefulWidget {
  const FavoriteToggle({super.key});

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
            size: 40,
          ),
          if (!isFavorited)
            Positioned(
              bottom: 11,
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 18,
              ),
            ),
          if (isFavorited)
            Positioned(
              bottom: 11,
              child: Icon(
                Icons.check,
                color: Color(0xFF121212),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}