import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/services/auth_service.dart';

class RatingService {
  final AuthService _authService;
  final String _baseUrl = 'https://cinecritique.mi.hdm-stuttgart.de/api/reviews';

  RatingService(this._authService) {
    print('RatingService: Initialized with base URL: $_baseUrl');
  }

  Future<List<Map<String, dynamic>>> getReviews(String imdbId) async {
    print('RatingService: Fetching reviews for movie ID: $imdbId');
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('RatingService: No token available for getting reviews');
        return [];
      }
      print('RatingService: Token retrieved successfully');

      final movieUrl = 'https://cinecritique.mi.hdm-stuttgart.de/api/movies/$imdbId';
      print('RatingService: Making GET request to: $movieUrl');

      final response = await http.get(
        Uri.parse(movieUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final movieData = json.decode(response.body);
        print('RatingService: Movie data received: $movieData');
        
        final List<dynamic> reviewIds = movieData['reviewIds'] ?? [];
        print('RatingService: Found ${reviewIds.length} reviewIds');
        
        final List<Map<String, dynamic>> reviews = reviewIds.map((review) {
          if (review is Map<String, dynamic>) {
            return {
              'rating': review['rating'] ?? 0,
              'body': review['body'] ?? '',
              'createdBy': review['createdBy'] ?? 'Unknown',
            };
          }
          return {
            'rating': 0,
            'body': '',
            'createdBy': 'Unknown',
          };
        }).toList();
        
        print('RatingService: Successfully parsed ${reviews.length} reviews');
        return reviews;
      } else {
        print('RatingService: Failed to get movie data: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      print('RatingService: Error getting reviews: $e');
      print('RatingService: Stack trace: $stackTrace');
      return [];
    }
  }

  Future<bool> createReview(String imdbId, String reviewText, int rating) async {
    print('RatingService: Creating review for movie ID: $imdbId');
    print('RatingService: Review details - Rating: $rating, Text length: ${reviewText.length}');
    
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('RatingService: No token available for creating review');
        return false;
      }
      print('RatingService: Token retrieved successfully');

      final url = '$_baseUrl/create';
      print('RatingService: Making POST request to: $url');

      final body = {
        'imdbId': imdbId,
        'body': reviewText,
        'rating': rating,
      };
      print('RatingService: Request body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('RatingService: Create review response status: ${response.statusCode}');
      print('RatingService: Create review response body: ${response.body}');

      final success = response.statusCode == 201;
      print('RatingService: Review creation ${success ? 'successful' : 'failed'}');
      return success;
    } catch (e, stackTrace) {
      print('RatingService: Error creating review: $e');
      print('RatingService: Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> deleteReview(String imdbId) async {
    print('RatingService: Deleting review for movie ID: $imdbId');
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('RatingService: No token available for deleting review');
        return false;
      }
      print('RatingService: Token retrieved successfully');

      final url = '$_baseUrl/remove?imdbId=$imdbId';
      print('RatingService: Making DELETE request to: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('RatingService: Delete review response status: ${response.statusCode}');
      print('RatingService: Delete review response body: ${response.body}');

      final success = response.statusCode == 200;
      print('RatingService: Review deletion ${success ? 'successful' : 'failed'}');
      return success;
    } catch (e, stackTrace) {
      print('RatingService: Error deleting review: $e');
      print('RatingService: Stack trace: $stackTrace');
      return false;
    }
  }

  double calculateAverageRating(List<Map<String, dynamic>> reviews) {
    print('RatingService: Calculating average rating for ${reviews.length} reviews');
    if (reviews.isEmpty) {
      print('RatingService: No reviews available, returning 0.0');
      return 0.0;
    }
    
    final totalRating = reviews.fold<int>(
      0,
      (sum, review) => sum + (review['rating'] as int? ?? 0),
    );
    
    final average = totalRating / reviews.length;
    print('RatingService: Calculated average rating: $average');
    return average;
  }

  String formatUsername(String email) {
    print('RatingService: Formatting username from email: $email');
    final username = email.split('@').first;
    print('RatingService: Formatted username: $username');
    return username;
  }
}
