import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/services/auth_service.dart';

class UserService {
  final AuthService _authService;
  final String _baseUrl = 'https://cinecritique.mi.hdm-stuttgart.de/api';

  UserService(this._authService);

  Future<Map<String, dynamic>> getUserMe() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No token available');

      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }

  Future<List<String>> getRatedMovies(Map<String, dynamic> user) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No token available');

      final response = await http.get(
        Uri.parse('$_baseUrl/reviews/user/${user['id']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((movie) => movie['imdbId'].toString()).toList();
      } else {
        throw Exception('Failed to get rated movies');
      }
    } catch (e) {
      print('Error getting rated movies: $e');
      rethrow;
    }
  }
} 