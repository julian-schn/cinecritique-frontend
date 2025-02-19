import 'package:flutter/material.dart';
import 'package:flutter_app/screen/genre/single_genre.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'genre_card.dart'; // Dein GenreCard Widget
import 'package:flutter_app/services/auth_service.dart'; // Import von AuthService

class HorizontalGenreList extends StatefulWidget {
  final AuthService authService; // AuthService als Parameter

  const HorizontalGenreList({super.key, required this.authService});

  @override
  State<HorizontalGenreList> createState() => _HorizontalGenreListState();
}

class _HorizontalGenreListState extends State<HorizontalGenreList> {
  List<String> genres = [];
  bool isLoading = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchGenres();
  }

  Future<void> fetchGenres() async {
    try {
      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies/genre'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));

        Set<String> genreSet = {};

        data.forEach((key, value) {
          for (var movie in value) {
            if (movie['genres'] != null) {
              genreSet.addAll(List<String>.from(movie['genres']));
            }
          }
        });

        List<String> sortedGenres = genreSet.toList()..sort();

        setState(() {
          genres = sortedGenres;
          isLoading = false;
        });
      } else {
        print('Fehler: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Fehler beim Abrufen der Genres: $e');
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

    // Prüfe, ob es sich um ein mobiles Gerät handelt
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    // Passe die Höhe des Containers und der Cards an
    final double containerHeight = isMobile ? 100 : 140;
    final double cardWidth = isMobile ? 180 : 250;
    final double cardHeight = containerHeight;
    final double horizontalPadding = isMobile ? 30.0 : 50.0;
    final double arrowIconSize = isMobile ? 50 : 65;
    final double scrollOffset = isMobile ? 300 : 400;

    return Container(
      height: containerHeight,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return GestureDetector(
                  onTap: () {
                    // Öffnet die GenreDetailPage mit dem entsprechenden Genre und authService
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenreDetailPage(
                          genre: genre,
                          authService: widget.authService,
                        ),
                      ),
                    );
                  },
                  child: GenreCard(
                    genre: genre,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                  ),
                );
              },
            ),
          ),
          // Pfeile zum Scrollen nach links
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
          // Pfeile zum Scrollen nach rechts
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
