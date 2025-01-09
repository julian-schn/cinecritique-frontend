import 'package:flutter/material.dart';

class FavoriteToggle extends StatefulWidget {
  const FavoriteToggle({Key? key}) : super(key: key);

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
            color: Colors.black,
            size: 50,
          ),
          if (!isFavorited)
            Positioned(
              bottom: 16,
              child: Icon(
                Icons.add,
                color: Colors.black,
                size: 20,
              ),
            ),
          if (isFavorited)
            Positioned(
              bottom: 16,
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}