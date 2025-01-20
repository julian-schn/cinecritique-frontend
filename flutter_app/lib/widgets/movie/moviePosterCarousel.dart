import 'dart:async'; // Für Timer
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class MoviePosterCarousel extends StatefulWidget {
  const MoviePosterCarousel({Key? key}) : super(key: key);

  @override
  State<MoviePosterCarousel> createState() => _MoviePosterCarouselState();
}

class _MoviePosterCarouselState extends State<MoviePosterCarousel> {
  List<Map<String, dynamic>> movies = [];
  bool isLoading = true;
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchMovies();

    // Timer, um alle 15 Sekunden den Film zu wechseln
    _timer = Timer.periodic(const Duration(seconds: 15), (Timer timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % movies.length;
      });
    });
  }

  Future<void> fetchMovies() async {
    try {
      final response = await http.get(
        Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> loadedMovies = data.map((movie) {
          // Verwende das erste Bild aus 'backdrops'
          return {
            'poster': movie['backdrops']?.isNotEmpty == true ? movie['backdrops'][0] : '', // Hole das erste Bild aus dem 'backdrops'-Array
          };
        }).toList();

        // Zufällige Reihenfolge der Filme
        loadedMovies.shuffle(Random());

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

  @override
  void dispose() {
    // Timer stoppen, wenn das Widget aus dem Baum entfernt wird
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: Container(
              height: 400,
              width: 800,
              child: AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: ClipRRect(
                  key: ValueKey<int>(_currentIndex), // Wichtiger Key für den Übergang
                  borderRadius: BorderRadius.circular(18.0),
                  child: Image.network(
                    movies[_currentIndex]['poster'] ?? '',
                    fit: BoxFit.cover,
                    width: 800,
                    height: 400,
                  ),
                ),
              ),
            ),
          );
  }
}
