import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/auth_service.dart';

class FavoriteController {
  final AuthService authService;

  FavoriteController(this.authService);

  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final token = await authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/users/favorites/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
    } catch (e) {
      print('Error fetching favorites: $e');
    }
    return [];
  }

  Future<bool> addFavorite(String imdbId) async {
    try {
      final token = await authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/users/favorites/add?imdbId=$imdbId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final message = json.decode(response.body);
        print('Add favorite response: $message');
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding favorite: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(String imdbId) async {
    try {
      final token = await authService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/users/favorites/remove?imdbId=$imdbId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final message = json.decode(response.body);
        print('Remove favorite response: $message');
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing favorite: $e');
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