import 'dart:convert';
import 'package:http/http.dart' as http;

class GenreController {
  // Methode zum Abrufen aller Genres
  Future<List<String>> fetchAllGenres() async {
    try {
      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies/genre'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        Set<String> genreSet = {};

        data.forEach((key, value) {
          for (var movie in value) {
            if (movie['genres'] != null) {
              genreSet.addAll(List<String>.from(movie['genres']));
            }
          }
        });

        List<String> sortedGenres = genreSet.toList()..sort();
        return sortedGenres;
      } else {
        print('Fehler beim Abrufen der Genres: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Fehler: $e');
      return [];
    }
  }
}
