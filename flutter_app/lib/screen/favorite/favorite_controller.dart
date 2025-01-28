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
        final List<Map<String, dynamic>> favorites = List<Map<String, dynamic>>.from(json.decode(response.body));
        print('FavoriteController: Successfully fetched ${favorites.length} favorites');
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
        final message = json.decode(response.body);
        print('FavoriteController: Successfully added favorite. Response: $message');
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
        final message = json.decode(response.body);
        print('FavoriteController: Successfully removed favorite. Response: $message');
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

/*  Endpoinnnt implementation for Favorites in backend

        // Endpoint to add a movie to a users favoritelist
    @PostMapping("/favorites/add")
    @PreAuthorize("hasRole('client_user') or hasRole('client_admin')")
    public ResponseEntity<String> addFavorite(Authentication authentication, @RequestParam String imdbId) {
        String message = userService.addFavoriteMovie(authentication, imdbId);
        return ResponseEntity.ok(message); // Return success or error message
    }

    // Endpoint to remove a movie from a users favoritelist
    @DeleteMapping("/favorites/remove")
    @PreAuthorize("hasRole('client_user') or hasRole('client_admin')")
    public ResponseEntity<String> removeFavorite(Authentication authentication, @RequestParam String imdbId) {
        String message = userService.removeFavoriteMovie(authentication, imdbId);
        return ResponseEntity.ok(message); // Return success or error message
    }

    // Endpoint get a users favoritelist
    @GetMapping("/favorites/all")
    @PreAuthorize("hasRole('client_user') or hasRole('client_admin')")
    public ResponseEntity<List<Movie>> getFavorites(Authentication authentication) {
        List<Movie> favorites = userService.getFavoriteMovies(authentication);
        return ResponseEntity.ok(favorites); // Return list of favorite movies
    }


*/