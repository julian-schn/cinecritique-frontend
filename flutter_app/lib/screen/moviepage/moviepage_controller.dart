import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/movie_service.dart';
import 'package:flutter_app/services/auth_service.dart';

class MoviePageController {
  final MovieService _movieService = MovieService(AuthService());

  Future<Map<String, dynamic>> fetchMovieDetails(String imdbId) async {
    try {
      final movie = await _movieService.getMovie(imdbId);
      return movie;
    } catch (e) {
      print('Error fetching movie details: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getReviews(String imdbId) async {
    try {
      final movie = await _movieService.getMovie(imdbId);
      return List<Map<String, dynamic>>.from(movie['reviewIds'] ?? []);
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }
}

