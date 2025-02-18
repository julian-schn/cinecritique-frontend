import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:flutter_app/screen/rating/rating_screen.dart';
import 'package:flutter_app/screen/userprofile/userprofile_screen.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/movie_card.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/screen/recommendationns/recommenndations_page.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';

class GenreDetailPage extends StatefulWidget {
  final String genre;
  final AuthService authService;
  const GenreDetailPage({Key? key, required this.genre, required this.authService}) : super(key: key);

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
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final bool isSidebarExpanded = MediaQuery.of(context).size.width > 800;
    final headerRow = Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          if (isMobile) const SizedBox(width: 8),
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
    );
    final content = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: isSidebarExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          headerRow,
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 35.0, top: 10, bottom: 1),
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: isSidebarExpanded ? 16.0 : 48.0,
                runSpacing: 16.0,
                children: movies.map((movie) => Container(
                  width: 250,
                  height: 250,
                  child: MovieCard(
                    posterUrl: movie['poster'] ?? '',
                    title: movie['title'] ?? 'Unbekannt',
                    imdbId: movie['imdbId'] ?? '',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MoviePage(
                            imdbId: movie['imdbId'],
                            authService: widget.authService,
                          ),
                        ),
                      );
                    },
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
    final sidebar = Sidebar(
      authService: widget.authService,
      onHomePressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(authService: widget.authService)),
        );
      },
      onGenresPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GenrePage(authService: widget.authService)),
        );
      },
      onFavoritesPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FavoriteScreen(authService: widget.authService)),
        );
      },
      onRecommendationsPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RecommendationsPage(authService: widget.authService)),
        );
      },
      onRatingsPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RatingScreen(authService: widget.authService)),
        );
      },
      onProfilPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen(authService: widget.authService)),
        );
      },
      onLoginPressed: () {
        widget.authService.login();
      },
      onLogoutPressed: () {
        widget.authService.logout();
      },
      currentPage: 'Genre',
    );
    if (isMobile) {
      return Scaffold(
        drawer: sidebar,
        body: Stack(
          children: [
            SingleChildScrollView(child: content),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            sidebar,
            Expanded(
              child: isLoading ? const Center(child: CircularProgressIndicator()) : content,
            ),
          ],
        ),
      );
    }
  }
}
