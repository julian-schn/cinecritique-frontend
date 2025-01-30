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
        print('Raw Movie data received: $data');
        print('ReviewIds type: ${data['reviewIds']?.runtimeType}');
        print('ReviewIds content: ${data['reviewIds']}');

        // Überprüfen und Umwandeln von 'reviewIds' und 'createdBy'
        if (data['reviewIds'] != null) {
          try {
            final reviews = List<Map<String, dynamic>>.from(data['reviewIds']);
            print('Reviews after conversion: $reviews');
            
            data['reviewIds'] = reviews.map((review) {
              print('Processing review: $review');
              final processed = {
                'rating': review['rating'] ?? 0,
                'body': review['body'] ?? '',
                'createdBy': review['createdBy'] ?? 'Unknown',
              };
              print('Processed review: $processed');
              return processed;
            }).toList();
            
            print('Final reviews: ${data['reviewIds']}');
            
            // Calculate average rating
            if (reviews.isNotEmpty) {
              final totalRating = reviews.fold<int>(
                0,
                (sum, review) => sum + (review['rating'] as int? ?? 0),
              );
              data['averageRating'] = totalRating / reviews.length;
              print('Average rating calculated: ${data['averageRating']}');
            } else {
              data['averageRating'] = 0.0;
            }
          } catch (e) {
            print('Error processing reviews: $e');
            data['reviewIds'] = [];
            data['averageRating'] = 0.0;
          }
        } else {
          data['reviewIds'] = [];
          data['averageRating'] = 0.0;
        }

        if (data['backdrops'] != null) {
          data['backdrops'] = List<String>.from(data['backdrops']);
        }

        print('Final data being returned: $data');
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
