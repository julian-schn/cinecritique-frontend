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
        print('RatingController: Movie IDs: $ratedMovieIds'); // Debug print
        
        // Fetch details for each movie
        final List<Map<String, dynamic>> moviesWithDetails = [];
        for (var movieId in ratedMovieIds) { // Removed String type constraint
          final movieResponse = await http.get(
            Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies/$movieId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          
          if (movieResponse.statusCode == 200) {
            final movieData = json.decode(movieResponse.body) as Map<String, dynamic>;
            final userEmail = await _authService.getUserEmail();
            
            try {
              final reviews = movieData['reviews'] as List<dynamic>? ?? [];
              final userReview = reviews.firstWhere(
                (review) => review['createdBy'] == userEmail,
                orElse: () => null,
              );
              
              if (userReview != null) {
                moviesWithDetails.add({
                  ...movieData,
                  'userRating': userReview['rating'],
                  'userReview': userReview['body'],
                });
              }
            } catch (e) {
              print('RatingController: Error processing movie $movieId: $e');
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

  Future<List<Map<String, dynamic>>> getRatedMovies(AuthService authService) async {
    print('RatingController: Starting to fetch rated movies');
    try {
      print('RatingController: Calling getReviews on RatingService');
      final reviews = await _ratingService.getReviews('user');
      print('RatingController: Successfully received ${reviews.length} reviews from service');
      if (reviews.isNotEmpty) {
        print('RatingController: Sample review data - Title: ${reviews.first['title']}, Rating: ${reviews.first['rating']}');
      }
      return reviews;
    } catch (e, stackTrace) {
      print('RatingController: Exception occurred while fetching rated movies: $e');
      print('RatingController: Stack trace: $stackTrace');
      return [];
    }
  }

  // Get all reviews for a specific movie
  Future<List<Map<String, dynamic>>> getMovieReviews(String imdbId, AuthService authService) async {
    print('RatingController: Starting to fetch reviews for movie: $imdbId');
    try {
      print('RatingController: Calling getReviews on RatingService');
      final reviews = await _ratingService.getReviews(imdbId);
      print('RatingController: Successfully received ${reviews.length} reviews for movie');
      if (reviews.isNotEmpty) {
        print('RatingController: Sample review data - Rating: ${reviews.first['rating']}, User: ${reviews.first['createdBy']}');
      }
      return reviews;
    } catch (e, stackTrace) {
      print('RatingController: Exception occurred while fetching movie reviews: $e');
      print('RatingController: Stack trace: $stackTrace');
      return [];
    }
  }

  // Create a new review
  Future<bool> createReview(String imdbId, String reviewText, int rating) async {
    print('RatingController: Creating review - Movie: $imdbId, Rating: $rating');
    try {
      print('RatingController: Calling createReview on RatingService');
      final success = await _ratingService.createReview(imdbId, reviewText, rating);
      print('RatingController: Review creation ${success ? 'successful' : 'failed'}');
      return success;
    } catch (e, stackTrace) {
      print('RatingController: Exception occurred while creating review: $e');
      print('RatingController: Stack trace: $stackTrace');
      return false;
    }
  }

  // Delete a review
  Future<bool> deleteReview(String imdbId) async {
    print('RatingController: Deleting review for movie: $imdbId');
    try {
      print('RatingController: Calling deleteReview on RatingService');
      final success = await _ratingService.deleteReview(imdbId);
      print('RatingController: Review deletion ${success ? 'successful' : 'failed'}');
      return success;
    } catch (e, stackTrace) {
      print('RatingController: Exception occurred while deleting review: $e');
      print('RatingController: Stack trace: $stackTrace');
      return false;
    }
  }

  // Calculate average rating from reviews
  double calculateAverageRating(List<Map<String, dynamic>> reviews) {
    print('RatingController: Calculating average rating for ${reviews.length} reviews');
    final average = _ratingService.calculateAverageRating(reviews);
    print('RatingController: Calculated average rating: $average');
    return average;
  }

  // Format username from email
  String formatUsername(String email) {
    print('RatingController: Formatting username from email: $email');
    final username = _ratingService.formatUsername(email);
    print('RatingController: Formatted username: $username');
    return username;
  }
}
