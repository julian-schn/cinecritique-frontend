import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'movie_card.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart'; // Importiere deine MoviePageScreen-Datei

class HorizontalMovieList extends StatefulWidget {
  const HorizontalMovieList({Key? key}) : super(key: key);

  @override
  State<HorizontalMovieList> createState() => _HorizontalMovieListState();
}

class _HorizontalMovieListState extends State<HorizontalMovieList> {
  List<Map<String, dynamic>> movies = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> loadedMovies = data.map((movie) {
          return {
            'poster': movie['poster'] ?? '',
            'title': movie['title'] ?? 'Unknown',
            'imdbId': movie['imdbId'] ?? '', // IMDb-ID hinzufügen
          };
        }).toList();

        setState(() {
          movies = loadedMovies;
          isLoading = false;
        });
      } else {
        print('Fehler: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Fehler beim Abrufen der Filme: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            height: 250,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      return MovieCard(
                        posterUrl: movies[index]['poster'] ?? '',
                        title: movies[index]['title'] ?? 'Unknown',
                        imdbId: movies[index]['imdbId'] ?? '', // IMDb-ID übergeben#

                        onTap: () {
                          // Navigation zur MoviePage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoviePage(
                                imdbId: movies[index]['imdbId'] ?? '',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                
                Positioned(
                  left: 0,
                  top: 92.5,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: scrollLeft,
                      child: const Icon(
                        Icons.arrow_left,
                        size: 65,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                
                Positioned(
                  right: 0,
                  top: 92.5,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: scrollRight,
                      child: const Icon(
                        Icons.arrow_right,
                        size: 65,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
