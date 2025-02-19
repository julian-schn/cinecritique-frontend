import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'movie_card.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:flutter_app/services/auth_service.dart';

class HorizontalMovieList extends StatefulWidget {
  final String? genre; // Genre optional
  final AuthService authService; // AuthService als Parameter

  const HorizontalMovieList({Key? key, this.genre, required this.authService})
      : super(key: key);

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
    if (widget.genre == null) {
      fetchAllMovies(); // Wenn kein Genre angegeben, alle Filme abrufen
    } else {
      fetchMoviesByGenre(); // Sonst Filme basierend auf Genre abrufen
    }
  }

  Future<void> fetchAllMovies() async {
    try {
      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          movies = data.map((movie) {
            return {
              'poster': movie['poster'] ?? '',
              'title': movie['title'] ?? 'Unknown',
              'imdbId': movie['imdbId'] ?? '',
            };
          }).toList();
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

  Future<void> fetchMoviesByGenre() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://cinecritique.mi.hdm-stuttgart.de/api/movies/genre/${widget.genre}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          movies = data.map((movie) {
            return {
              'poster': movie['poster'] ?? '',
              'title': movie['title'] ?? 'Unknown',
              'imdbId': movie['imdbId'] ?? '',
            };
          }).toList();
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

  @override
  Widget build(BuildContext context) {
    // Für Mobile vs. Desktop: unterschiedliche Kartengrößen
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double containerHeight = isMobile ? 180 : 250;
    final double cardWidth = isMobile ? 180 : 250;
    final double cardHeight = isMobile ? 180 : 250;

    // **Hier verwenden wir dieselben Werte für Abstände/Pfeile**, 
    // um das Layout möglichst ähnlich zu halten
    final double horizontalPadding = 50.0;
    final double arrowIconSize = 65;
    final double scrollOffset = 400;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            height: containerHeight,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      return MovieCard(
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                        posterUrl: movies[index]['poster'] ?? '',
                        title: movies[index]['title'] ?? 'Unknown',
                        imdbId: movies[index]['imdbId'] ?? '',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoviePage(
                                imdbId: movies[index]['imdbId'] ?? '',
                                authService: widget.authService,
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
                  top: containerHeight / 2 - arrowIconSize / 2,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _scrollController.animateTo(
                          _scrollController.offset - scrollOffset,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Icon(
                        Icons.arrow_left,
                        size: arrowIconSize,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: containerHeight / 2 - arrowIconSize / 2,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _scrollController.animateTo(
                          _scrollController.offset + scrollOffset,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Icon(
                        Icons.arrow_right,
                        size: arrowIconSize,
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
