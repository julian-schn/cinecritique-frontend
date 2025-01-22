import 'dart:convert';
import 'package:http/http.dart' as http;

class MoviePageController {
  Future<Map<String, dynamic>?> fetchMovieDetails(String imdbId) async {
    try {
      final response = await http
          .get(Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies/$imdbId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        // Überprüfen und Umwandeln von 'reviewIds' und 'createdBy'
        if (data['reviewIds'] != null) {
          data['reviewIds'] = List<Map<String, dynamic>>.from(data['reviewIds']).map((review) {
            // Wir nehmen 'createdBy' direkt, ohne nach 'user' oder 'username' zu suchen
            if (review['createdBy'] != null) {
              review['createdBy'] = review['createdBy'];
            }
            return review;
          }).toList();
        }

        if (data['backdrops'] != null) {
          data['backdrops'] = List<String>.from(data['backdrops']);
        }

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

