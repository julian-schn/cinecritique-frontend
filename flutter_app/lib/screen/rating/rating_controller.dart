import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/auth_service.dart';

class RatingController {
  final AuthService _authService;

  RatingController(this._authService);

  /// Ruft alle Reviews des aktuell angemeldeten Nutzers ab und kombiniert sie mit den entsprechenden Filmdetails.
  Future<List<Map<String, dynamic>>> getUserReviewsWithMovieDetails() async {
    print('RatingController: Starting to fetch user reviews with movie details');
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('RatingController: No token available');
        return [];
      }
      
      // API-Aufruf an den neuen Endpoint, der alle Reviews des Users liefert.
      final reviewsResponse = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/reviews/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('RatingController: Get reviews response status: ${reviewsResponse.statusCode}');
      if (reviewsResponse.statusCode != 200) {
        print('RatingController: Failed to fetch reviews.');
        return [];
      }

      final List<Map<String, dynamic>> reviews =
          List<Map<String, dynamic>>.from(json.decode(utf8.decode(reviewsResponse.bodyBytes)));
      print('RatingController: Successfully fetched ${reviews.length} reviews');

      List<Map<String, dynamic>> reviewsWithMovieDetails = [];

      // Für jedes Review die Filmdetails abrufen
      for (var review in reviews) {
        final imdbId = review['imdbId'];
        final movieResponse = await http.get(
          Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies/$imdbId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (movieResponse.statusCode == 200) {
          final movieData = json.decode(movieResponse.body) as Map<String, dynamic>;
          // Kombiniere die relevanten Filmdetails mit den Review-Daten
          Map<String, dynamic> combinedData = {
            'imdbId': imdbId,
            'movieTitle': movieData['title'],
            'moviePoster': movieData['poster'],
            'reviewBody': review['body'],
            'reviewRating': review['rating'],
            // Füge ggf. weitere Felder hinzu
          };
          reviewsWithMovieDetails.add(combinedData);
          print('RatingController: Added review for movie "$movieData[\'title\']"');
        } else {
          print('RatingController: Failed to fetch movie details for imdbId: $imdbId');
        }
      }

      return reviewsWithMovieDetails;
    } catch (e) {
      print('RatingController: Error fetching reviews with movie details: $e');
      return [];
    }
  }
}
