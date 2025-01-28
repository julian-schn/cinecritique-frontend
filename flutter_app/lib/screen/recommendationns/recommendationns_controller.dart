import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/auth_service.dart';

class RecommendationsController {
  Future<List<Map<String, dynamic>>> fetchRecommendations(AuthService authService) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        print('No access token available');
        return [];
      }

      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies/recommendation'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Error fetching recommendations: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}

/*  Endpoinnnt implementation for AI Recommendations in backend
    @GetMapping("/recommendation")
    @PreAuthorize("hasRole('client_user') or hasRole('client_admin')")
    public ResponseEntity<List<Map<String, Object>>> getRecommendations(Authentication authentication) {
        String email = authentication.getName();
        List<Map<String, Object>> recoMovies = recommendationService.getRecommendations(email);
        return ResponseEntity.ok(recoMovies);
    }
}
*/