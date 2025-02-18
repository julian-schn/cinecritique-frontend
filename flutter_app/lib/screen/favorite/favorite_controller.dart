import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/auth_service.dart';

class FavoriteController {
  final AuthService authService;

  FavoriteController(this.authService);

  Future<List<Map<String, dynamic>>> getFavorites() async {
    print('FavoriteController: Starting to fetch favorites');
    try {
      final token = await authService.getToken();
      if (token == null) {
        print('FavoriteController: No access token available');
        return [];
      }
      print('FavoriteController: Got token, making API call to fetch favorites...');

      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/users/favorites/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('FavoriteController: Get favorites response status: ${response.statusCode}');
      print('FavoriteController: Get favorites response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> favorites =
            List<Map<String, dynamic>>.from(
          json.decode(utf8.decode(response.bodyBytes)),
        );

        print('FavoriteController: Successfully fetched ${favorites.length} favorites');

        // **Alphabetisch (case-insensitive) nach 'title' sortieren**
        favorites.sort((a, b) {
          final titleA = (a['title'] ?? '').toLowerCase();
          final titleB = (b['title'] ?? '').toLowerCase();
          return titleA.compareTo(titleB);
        });

        return favorites;
      }
    } catch (e) {
      print('FavoriteController: Error fetching favorites: $e');
      print('FavoriteController: Stack trace: ${StackTrace.current}');
    }
    return [];
  }

  Future<bool> addFavorite(String imdbId) async {
    print('FavoriteController: Starting to add favorite for movie: $imdbId');
    try {
      final token = await authService.getToken();
      if (token == null) {
        print('FavoriteController: No access token available for adding favorite');
        return false;
      }
      print('FavoriteController: Got token, making API call to add favorite...');

      final response = await http.post(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/users/favorites/add?imdbId=$imdbId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('FavoriteController: Add favorite response status: ${response.statusCode}');
      print('FavoriteController: Add favorite response body: ${response.body}');

      if (response.statusCode == 200) {
        print('FavoriteController: Successfully added favorite: ${response.body}');
        return true;
      }
      print('FavoriteController: Failed to add favorite. Status: ${response.statusCode}');
      return false;
    } catch (e) {
      print('FavoriteController: Error adding favorite: $e');
      print('FavoriteController: Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  Future<bool> removeFavorite(String imdbId) async {
    print('FavoriteController: Starting to remove favorite for movie: $imdbId');
    try {
      final token = await authService.getToken();
      if (token == null) {
        print('FavoriteController: No access token available for removing favorite');
        return false;
      }
      print('FavoriteController: Got token, making API call to remove favorite...');

      final response = await http.delete(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/users/favorites/remove?imdbId=$imdbId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('FavoriteController: Remove favorite response status: ${response.statusCode}');
      print('FavoriteController: Remove favorite response body: ${response.body}');

      if (response.statusCode == 200) {
        print('FavoriteController: Successfully removed favorite: ${response.body}');
        return true;
      }
      print('FavoriteController: Failed to remove favorite. Status: ${response.statusCode}');
      return false;
    } catch (e) {
      print('FavoriteController: Error removing favorite: $e');
      print('FavoriteController: Stack trace: ${StackTrace.current}');
      return false;
    }
  }
}
