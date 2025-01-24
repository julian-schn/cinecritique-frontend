import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/screen/login/login_screen.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
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

    bool isSidebarExpanded = MediaQuery.of(context).size.width > 800; // Sidebar-Status abfragen

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            onHomePressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            onGenresPressed: () {
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GenrePage()),
              );
            },
            onLoginPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            currentPage: 'SingelGenre',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
  padding: const EdgeInsets.only(left: 35.0, top: 85.0, bottom: 8),
  child: Row(
    children: [
      Text(
        widget.genre,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Text(
        '.',
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 38,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),
Padding(
  padding: const EdgeInsets.only(left: 10, top: 10, bottom: 1),
  child: GridView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: isSidebarExpanded ? 4 : 5,
      crossAxisSpacing: 24.0,
      mainAxisSpacing: 24.0,
    ),
    itemCount: movies.length,
    itemBuilder: (context, index) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: MovieCard(
            posterUrl: movies[index]['poster'] ?? '',
            title: movies[index]['title'] ?? 'Unbekannt',
            imdbId: movies[index]['imdbId'] ?? '',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoviePage(imdbId: movies[index]['imdbId']),
                ),
              );
            },
          ),
        ),
      );
    },
  ),
)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
