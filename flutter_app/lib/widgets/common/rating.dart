import 'package:flutter/material.dart';
import 'package:flutter_app/services/rating_service.dart';
import 'package:flutter_app/services/auth_service.dart';

class DisplayRatingWidget extends StatefulWidget {
  final String imdbId;
  final AuthService authService;

  const DisplayRatingWidget({
    Key? key,
    required this.imdbId,
    required this.authService,
  }) : super(key: key);

  @override
  _DisplayRatingWidgetState createState() => _DisplayRatingWidgetState();
}

class _DisplayRatingWidgetState extends State<DisplayRatingWidget> {
  late final RatingService _ratingService;
  double averageRating = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _ratingService = RatingService(widget.authService);
    _loadAverageRating();
  }

  Future<void> _loadAverageRating() async {
    setState(() {
      isLoading = true;
    });

    final reviews = await _ratingService.getReviews(widget.imdbId);
    final average = _ratingService.calculateAverageRating(reviews);

    setState(() {
      averageRating = average;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
