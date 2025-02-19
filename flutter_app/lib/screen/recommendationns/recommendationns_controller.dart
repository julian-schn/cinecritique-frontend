import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/auth_service.dart';

class RecommendationsController {
  Future<List<Map<String, dynamic>>> fetchRecommendations(AuthService authService) async {
    print('RecommendationsController: Starting to fetch recommendations');
    try {
      final token = await authService.getToken();
      if (token == null) {
        print('RecommendationsController: No access token available');
        return [];
      }
      print('RecommendationsController: Got token, making API call...');

      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/ai/recommendation'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('RecommendationsController: API response status: ${response.statusCode}');
      print('RecommendationsController: API response body: ${response.body}');
      
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('RecommendationsController: Empty response body');
          return [];
        }
        
        try {
          final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
          print('RecommendationsController: Successfully decoded response data. Found ${data.length} recommendations');
          return List<Map<String, dynamic>>.from(data);
        } catch (e) {
          print('RecommendationsController: Error decoding response: $e');
          return [];
        }
      } else {
        print('RecommendationsController: Error response body: ${response.body}');
        print('Error fetching recommendations: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('RecommendationsController: Exception occurred: $e');
      print('RecommendationsController: Stack trace: ${StackTrace.current}');
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