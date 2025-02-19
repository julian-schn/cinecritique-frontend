import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/services/auth_service.dart';

class MovieService {
  final AuthService _authService;
  final String _baseUrl = 'https://cinecritique.mi.hdm-stuttgart.de/api/movies';

  MovieService(this._authService);

  Future<Map<String, dynamic>> getMovie(String imdbId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No token available');

      final response = await http.get(
        Uri.parse('$_baseUrl/$imdbId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get movie details');
      }
    } catch (e) {
      print('Error getting movie details: $e');
      rethrow;
    }
  }
} 