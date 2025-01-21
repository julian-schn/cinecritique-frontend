import 'package:flutter/material.dart';

class DisplayRatingWidget extends StatelessWidget {
  final double averageRating; 

  const DisplayRatingWidget({Key? key, required this.averageRating})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        
        Text(
          averageRating.toStringAsFixed(1), 
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8), 
        
        Row(
          children: List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 1.0),
              child: Icon(
                index < averageRating.floor()
                    ? Icons.star
                    : (index < averageRating
                        ? Icons.star_half
                        : Icons.star_border),
                color: Colors.white,
                size: 27, 
              ),
            );
          }),
        ),
      ],
    );
  }
}
