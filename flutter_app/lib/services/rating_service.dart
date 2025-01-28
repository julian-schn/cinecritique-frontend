import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/services/auth_service.dart';

class RatingService {
  final AuthService _authService;
  final String _baseUrl = 'https://cinecritique.mi.hdm-stuttgart.de/api/reviews';

  RatingService(this._authService) {
    print('RatingService: Initialized with base URL: $_baseUrl');
  }

  // Get all reviews for a movie
  Future<List<Map<String, dynamic>>> getReviews(String imdbId) async {
    print('RatingService: Fetching reviews for movie ID: $imdbId');
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('RatingService: No token available for getting reviews');
        return [];
      }
      print('RatingService: Token retrieved successfully');

      final url = '$_baseUrl/movie/$imdbId';
      print('RatingService: Making GET request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('RatingService: Get reviews response status: ${response.statusCode}');
      print('RatingService: Get reviews response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> reviewsJson = json.decode(response.body);
        print('RatingService: Successfully parsed ${reviewsJson.length} reviews');
        return reviewsJson.cast<Map<String, dynamic>>();
      } else {
        print('RatingService: Failed to get reviews: ${response.statusCode}');
        print('RatingService: Error response: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      print('RatingService: Error getting reviews: $e');
      print('RatingService: Stack trace: $stackTrace');
      return [];
    }
  }

  // Create a new review
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

  // Delete a review
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

  // Calculate average rating from reviews
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

  // Format username from email
  String formatUsername(String email) {
    print('RatingService: Formatting username from email: $email');
    final username = email.split('@').first;
    print('RatingService: Formatted username: $username');
    return username;
  }
}

/* Endpoint implementations for reviews in backend
    // Endpoint to create a new review
    @PostMapping("/create")
    @PreAuthorize("hasRole('client_user') or hasRole('client_admin')")
    public ResponseEntity<?> createReview(@RequestBody Review review, Authentication authentication) {
        // Retrieve the user's email from the authentication object
        String email = authentication.getName();
        review.setCreatedBy(email); // Set the email of the authenticated user
        review.setCreated(LocalDateTime.now()); // Set created timestamp
        review.setUpdated(LocalDateTime.now()); // Set updated timestamp

        // Check if the rating is provided and within a valid range
        if (review.getRating() != null && (review.getRating() < 1 || review.getRating() > 5)) {
            logger.error("Invalid rating value provided");
            return new ResponseEntity<>("Rating must be between 1 and 5", HttpStatus.BAD_REQUEST);
        }

        logger.info("Creating review for movie with ID: " + review.getImdbId() + " by user: " + email);
        Review createdReview = reviewService.createReview(review.getBody(), review.getRating(), review.getImdbId(), email);

        // Check if the review was created successfully
        if (createdReview != null) {
            return new ResponseEntity<>(createdReview, HttpStatus.CREATED);
        } else {
            logger.error("Error occurred creating the review");
            return new ResponseEntity<>("Could not create review. Check if the movie exists or if the user already reviewed it.", HttpStatus.BAD_REQUEST);
        }
    }

    // Endpoint to delete an existing review
    @DeleteMapping("/remove")
    @PreAuthorize("hasRole('client_user') or hasRole('client_admin')")
    public ResponseEntity<String> deleteReview(@RequestParam String imdbId, Authentication authentication) {
        String username = authentication.getName();
        logger.info("Deleting review for user " + username + " on movie " + imdbId);

        // Attempt to delete the review
        if (reviewService.deleteReview(username, imdbId)) {
            return new ResponseEntity<>("Review was deleted", HttpStatus.OK);
        } else {
            logger.error("Error occurred removing the review");
            return new ResponseEntity<>("An error occurred removing the review. The review might not exist.", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
*/
