import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/services/rating_service.dart';

class RatingController {
  final AuthService _authService;
  final ValueNotifier<List<Map<String, dynamic>>> ratedMovies = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  late final RatingService _ratingService;

  RatingController(this._authService) {
    print('RatingController: Initializing with AuthService');
    _ratingService = RatingService(_authService);
    print('RatingController: RatingService initialized');
  }

  Future<void> fetchRatedMovies() async {
    isLoading.value = true;
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('RatingController: No token available');
        return;
      }

      // Hole die Liste der bewerteten Movie-IDs
      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/users/rated-movies'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> ratedMovieIds = json.decode(response.body) as List<dynamic>;
        print('RatingController: Found ${ratedMovieIds.length} rated movies');

        final List<Map<String, dynamic>> moviesWithDetails = [];
        // Hole den aktuell angemeldeten Benutzernamen, formatiert
        final currentUsername = _authService.getUsername().toLowerCase().trim();

        // Iteriere über alle bewerteten Filme
        for (var movieId in ratedMovieIds) {
          final movieResponse = await http.get(
            Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies/$movieId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          if (movieResponse.statusCode == 200) {
            final movieData = json.decode(movieResponse.body) as Map<String, dynamic>;

            // Hole die Reviews für diesen Film (die Reviews kommen vom RatingService)
            final reviews = await _ratingService.getReviews(movieId.toString());

            // Filtere die Review, die vom aktuell angemeldeten Benutzer verfasst wurde
            final userReview = reviews.firstWhere(
              (review) {
                final reviewUsername = review['createdBy'].toString().toLowerCase().trim();
                // Debug-Log: Werte vergleichen
                print('Vergleiche reviewUsername: "$reviewUsername" mit currentUsername: "$currentUsername"');
                return reviewUsername == currentUsername;
              },
              orElse: () {
                print('Keine Review von $currentUsername für movieId $movieId gefunden.');
                return <String, dynamic>{};
              },
            );

            // Falls eine Review gefunden wurde, füge die Details hinzu
            if (userReview.isNotEmpty) {
              moviesWithDetails.add({
                ...movieData,
                'userRating': userReview['rating'],
                'userReview': userReview['body'],
              });
              print('Review von $currentUsername für movieId $movieId hinzugefügt.');
            }
          } else {
            print('RatingController: Failed to fetch movie $movieId: ${movieResponse.statusCode}');
          }
        }

        print('RatingController: Successfully fetched ${moviesWithDetails.length} movies with details');
        ratedMovies.value = moviesWithDetails;
      } else {
        print('RatingController: Failed to fetch rated movies. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('RatingController: Error fetching rated movies: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
