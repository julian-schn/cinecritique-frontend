import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/services/rating_service.dart';

class RatingController {
  late final RatingService _ratingService;

  RatingController(AuthService authService) {
    _ratingService = RatingService(authService);
  }

  Future<List<Map<String, dynamic>>> getRatedMovies(AuthService authService) async {
    print('RatingController: Starting to fetch rated movies');
    try {
      final reviews = await _ratingService.getReviews('user');
      print('RatingController: Successfully fetched ${reviews.length} rated movies');
      return reviews;
    } catch (e) {
      print('RatingController: Exception occurred: $e');
      print('RatingController: Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Get all reviews for a specific movie
  Future<List<Map<String, dynamic>>> getMovieReviews(String imdbId, AuthService authService) async {
    print('RatingController: Starting to fetch reviews for movie: $imdbId');
    try {
      final reviews = await _ratingService.getReviews(imdbId);
      print('RatingController: Successfully fetched ${reviews.length} reviews');
      return reviews;
    } catch (e) {
      print('RatingController: Exception occurred: $e');
      print('RatingController: Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Create a new review
  Future<bool> createReview(String imdbId, String reviewText, int rating) async {
    print('RatingController: Creating review for movie: $imdbId');
    try {
      final success = await _ratingService.createReview(imdbId, reviewText, rating);
      print('RatingController: Review creation ${success ? 'successful' : 'failed'}');
      return success;
    } catch (e) {
      print('RatingController: Exception occurred: $e');
      print('RatingController: Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Delete a review
  Future<bool> deleteReview(String imdbId) async {
    print('RatingController: Deleting review for movie: $imdbId');
    try {
      final success = await _ratingService.deleteReview(imdbId);
      print('RatingController: Review deletion ${success ? 'successful' : 'failed'}');
      return success;
    } catch (e) {
      print('RatingController: Exception occurred: $e');
      print('RatingController: Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Calculate average rating from reviews
  double calculateAverageRating(List<Map<String, dynamic>> reviews) {
    return _ratingService.calculateAverageRating(reviews);
  }

  // Format username from email
  String formatUsername(String email) {
    return _ratingService.formatUsername(email);
  }
}
