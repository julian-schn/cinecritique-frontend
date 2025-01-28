import 'dart:convert';
import 'package:http/http.dart' as http;

class RecommendationsController {
  Future<List<String>> fetchRecommendations() async {
    try {
      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/ai/getrecommendations'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        
        // For now, we'll return a list with just one category "Recommendations"
        // This can be expanded later if we want to show different types of recommendations
        return ['Recommendations'];
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
