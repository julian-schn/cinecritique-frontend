import 'package:flutter/material.dart';

class BackdropCard extends StatelessWidget {
  final String backdropUrl;
  final VoidCallback onTap;

  const BackdropCard({
    Key? key,
    required this.backdropUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 240,
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              backdropUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey,
                  child: const Icon(Icons.image, color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}