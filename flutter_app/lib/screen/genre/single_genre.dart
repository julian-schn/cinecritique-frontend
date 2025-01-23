import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/login/login_screen.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/movie_card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GenreDetailPage extends StatefulWidget {
  final String genre;

  const GenreDetailPage({Key? key, required this.genre}) : super(key: key);

  @override
  _GenreDetailPageState createState() => _GenreDetailPageState();
}

class _GenreDetailPageState extends State<GenreDetailPage> {
  List<Map<String, dynamic>> movies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMoviesForGenre();
  }

  Future<void> fetchMoviesForGenre() async {
    try {
      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies/genre/${widget.genre}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          movies = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        print('Fehler: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Fehler beim Abrufen der Filme für Genre: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Row(  // Row für Sidebar und Hauptinhalt nebeneinander
        children: [
          Sidebar(  // Sidebar als linke Seite
            onHomePressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            onGenresPressed: () {
              print("Genres pressed");
            },
            onLoginPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            currentPage: 'SingelGenre',  
          ),
          Expanded(  // Hauptinhalt
            child: SingleChildScrollView(  // Scrollen für den Hauptinhalt
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
  padding: const EdgeInsets.only(left: 17.0, top: 50.0, bottom: 15),
  child: Row(
    children: [
      Text(
        widget.genre,  // Genre als Text anzeigen
        style: const TextStyle(
          color: Colors.white,  // Weiße Schriftfarbe
          fontSize: 34,          // Größere Schriftgröße
          fontWeight: FontWeight.bold,  // Fettschrift
        ),
      ),
      const SizedBox(width: 8.0),  // Abstand zwischen Genre und dem Punkt
      Text(
        '.',  // Trennzeichen Punkt
        style: const TextStyle(
          color: Colors.redAccent,  // Rote Schriftfarbe
          fontSize: 34,              // Etwas größere Schriftgröße für den Punkt
          fontWeight: FontWeight.bold,  // Fettschrift
        ),
      ),
    ],
  ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),  // Verhindert das Scrollen von GridView, da der ScrollView es übernimmt
                      shrinkWrap: true,  // Macht die GridView so, dass sie ihre Höhe automatisch anpasst
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // 4 Filme pro Reihe
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        return MovieCard(
                          posterUrl: movies[index]['poster'] ?? '',
                          title: movies[index]['title'] ?? 'Unbekannt',
                          imdbId: movies[index]['imdbId'] ?? '',
                          onTap: () {
                            // Hier kannst du die Logik hinzufügen, was passiert,
                            // wenn auf einen Film geklickt wird.
                            print('Film ${movies[index]['title']} wurde ausgewählt');
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
