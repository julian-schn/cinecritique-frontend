import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 900,  // Feste Breite für die Suchleiste ## @Lian, ich weiß nicht ob das sinnvoll ist, in anbetracht von responsive Design -Julian
      padding: const EdgeInsets.all(5.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Suche...',
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

