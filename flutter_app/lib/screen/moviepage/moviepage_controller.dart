import 'dart:convert';
import 'package:http/http.dart' as http;

class MoviePageController {
  Future<Map<String, dynamic>?> fetchMovieDetails(String imdbId) async {
    try {
      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies/$imdbId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('Fehler: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Fehler beim Abrufen der Filmdaten: $e');
      return null;
    }
  }
}
