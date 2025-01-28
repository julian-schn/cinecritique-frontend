import 'package:flutter/material.dart';
import 'package:flutter_app/services/rating_service.dart';
import 'package:flutter_app/services/auth_service.dart';

class ShowRatingWidget extends StatefulWidget {
  final String imdbId;
  final AuthService authService;

  const ShowRatingWidget({
    Key? key, 
    required this.imdbId,
    required this.authService,
  }) : super(key: key);

  @override
  _ShowRatingWidgetState createState() => _ShowRatingWidgetState();
}

class _ShowRatingWidgetState extends State<ShowRatingWidget> {
  late final RatingService _ratingService;
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('ShowRatingWidget: Initializing state');
    _ratingService = RatingService(widget.authService);
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    print('ShowRatingWidget: Starting to load reviews for movie ID: ${widget.imdbId}');
    setState(() {
      isLoading = true;
    });

    final loadedReviews = await _ratingService.getReviews(widget.imdbId);
    print('ShowRatingWidget: Loaded ${loadedReviews.length} reviews');
    
    setState(() {
      reviews = loadedReviews;
      isLoading = false;
    });
    print('ShowRatingWidget: Updated state with loaded reviews');
  }

  @override
  Widget build(BuildContext context) {
    print('ShowRatingWidget: Building widget, isLoading: $isLoading, reviews count: ${reviews.length}');
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bewertungen anderer",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (reviews.isEmpty)
            const Text(
              "Noch keine Bewertungen.",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            )
          else
            ...reviews.map((review) {
              print('ShowRatingWidget: Rendering review from user: ${review['createdBy']}');
              final int rating = review['rating'] ?? 0;
              final String userName = _ratingService.formatUsername(review['createdBy'] ?? 'Unbekannt');

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  color: const Color.fromARGB(255, 33, 33, 33),
                  margin: EdgeInsets.zero,
                  child: Container(
                    width: 450,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                )
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < rating ? Icons.star : Icons.star_border,
                                    color: Colors.white,
                                    size: 23,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            review['body'] ?? 'No review text available.',
                            style: const TextStyle(fontSize: 16, color: Colors.white)
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
