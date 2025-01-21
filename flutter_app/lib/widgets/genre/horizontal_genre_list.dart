import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'genre_card.dart'; 

class HorizontalGenreList extends StatefulWidget {
  const HorizontalGenreList({super.key});

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
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print("API response: $data");

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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: 140,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: genres.length,
              itemBuilder: (context, index) {
                return GenreCard(
                  genre: genres[index],
                  onTap: () {
                    print('Selected genre: ${genres[index]}');
                  },
                );
              },
            ),
          ),
           Positioned(
                  left: 0,
                  top: 42,
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
                  top: 42,
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