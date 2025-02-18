import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/genre/genre_controller.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/horizontal_movie_list.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/screen/recommendationns/recommenndations_page.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';
import 'package:flutter_app/screen/rating/rating_screen.dart';
import 'package:flutter_app/screen/userprofile/userprofile_screen.dart';

class GenrePage extends StatefulWidget {
  final AuthService authService;

  const GenrePage({Key? key, required this.authService}) : super(key: key);

  @override
  _GenrePageState createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  final GenreController _controller = GenreController();
  List<String> genres = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGenres();
  }

  Future<void> fetchGenres() async {
    try {
      final fetchedGenres = await _controller.fetchAllGenres();
      setState(() {
        genres = fetchedGenres;
        isLoading = false;
      });
    } catch (e) {
      print('Fehler beim Abrufen der Genres: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prüfe, ob es sich um ein mobiles Gerät handelt (unter 600px)
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    // Erstelle die Sidebar-Instanz mit den gleichen Callback-Funktionen wie bei FavoriteScreen
    final sidebar = Sidebar(
      authService: widget.authService,
      onHomePressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(authService: widget.authService),
          ),
        );
      },
      onGenresPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GenrePage(authService: widget.authService),
          ),
        );
      },
      onFavoritesPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FavoriteScreen(authService: widget.authService),
          ),
        );
      },
      onRecommendationsPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RecommendationsPage(authService: widget.authService),
          ),
        );
      },
      onRatingsPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RatingScreen(authService: widget.authService),
          ),
        );
      },
      onProfilPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UserProfileScreen(authService: widget.authService),
          ),
        );
      },
      onLoginPressed: () {
        widget.authService.login();
      },
      onLogoutPressed: () {
        widget.authService.logout();
      },
      currentPage: 'Genres', // aktueller Menüpunkt
    );

    // Hauptinhalt der Seite
    final content = Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : genres.isEmpty
              ? const Center(
                  child: Text(
                    'Keine Genres gefunden.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    return Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                genre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                '.',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          HorizontalMovieList(
                            genre: genre,
                            authService: widget.authService,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
    );

    // Je nach Gerätegröße: mobile Variante mit Drawer oder Desktop-Variante mit fester Sidebar
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Genres'),
        ),
        drawer: sidebar,
        body: content,
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            sidebar,
            Expanded(child: content),
          ],
        ),
      );
    }
  }
}
