import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/services/auth_service.dart';

class RatingService {
  final AuthService _authService;
  final String _baseUrl = 'http://localhost:8080/api/v1/reviews';

  RatingService(this._authService);

  // Get all reviews for a movie
  Future<List<Map<String, dynamic>>> getReviews(String imdbId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('No token available for getting reviews');
        return [];
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/movie/$imdbId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Get reviews response status: ${response.statusCode}');
      print('Get reviews response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> reviewsJson = json.decode(response.body);
        return reviewsJson.cast<Map<String, dynamic>>();
      } else {
        print('Failed to get reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting reviews: $e');
      return [];
    }
  }

  // Create a new review
  Future<bool> createReview(String imdbId, String reviewText, int rating) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('No token available for creating review');
        return false;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'imdbId': imdbId,
          'body': reviewText,
          'rating': rating,
        }),
      );

      print('Create review response status: ${response.statusCode}');
      print('Create review response body: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating review: $e');
      return false;
    }
  }

  // Delete a review
  Future<bool> deleteReview(String imdbId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('No token available for deleting review');
        return false;
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/remove?imdbId=$imdbId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Delete review response status: ${response.statusCode}');
      print('Delete review response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  // Calculate average rating from reviews
  double calculateAverageRating(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return 0.0;
    
    final totalRating = reviews.fold<int>(
      0,
      (sum, review) => sum + (review['rating'] as int? ?? 0),
    );
    
    return totalRating / reviews.length;
  }

  // Format username from email
  String formatUsername(String email) {
    return email.split('@').first;
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
