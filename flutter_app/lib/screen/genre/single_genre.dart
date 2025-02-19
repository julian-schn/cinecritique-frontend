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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchMoviesForGenre();
  }

  Future<void> fetchMoviesForGenre() async {
    try {
      final response = await http.get(Uri.parse('https://cinecritique.mi.hdm-stuttgart.de/api/movies/genre/${widget.genre}'));
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
    final sidebar = Sidebar(
      authService: widget.authService,
      onHomePressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(authService: widget.authService)));
      },
      onGenresPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GenrePage(authService: widget.authService)));
      },
      onFavoritesPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FavoriteScreen(authService: widget.authService)));
      },
      onRecommendationsPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RecommendationsPage(authService: widget.authService)));
      },
      onRatingsPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RatingScreen(authService: widget.authService)));
      },
      onProfilPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserProfileScreen(authService: widget.authService)));
      },
      onLoginPressed: () {
        widget.authService.login();
      },
      onLogoutPressed: () {
        widget.authService.logout();
      },
      currentPage: 'Genre',
    );
    final headerRow = isMobile
        ? Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              children: [
                Text(widget.genre, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('.', style: TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.only(
              left: isSidebarExpanded ? 20.0 : (MediaQuery.of(context).size.width - 1060) / 2,
              right: 35.0,
              top: 85.0,
              bottom: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.genre, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const Text('.', style: TextStyle(color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          );
    Widget movieContent;
    if (isLoading) {
      movieContent = const Center(child: CircularProgressIndicator());
    } else if (movies.isEmpty) {
      movieContent = const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text('Keine Filme in diesem Genre gefunden.', style: TextStyle(color: Colors.white, fontSize: 18))),
      );
    } else {
      final double cardSize = isMobile ? 180.0 : 250.0;
      movieContent = Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 35.0, top: 10, bottom: 8),
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: isSidebarExpanded ? 16.0 : 48.0,
            runSpacing: 16.0,
            children: movies.map((movie) {
              return SizedBox(
                width: cardSize,
                height: cardSize,
                child: MovieCard(
                  posterUrl: movie['poster'] ?? '',
                  title: movie['title'] ?? 'Unbekannt',
                  imdbId: movie['imdbId'] ?? '',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MoviePage(imdbId: movie['imdbId'], authService: widget.authService)),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
    final content = SingleChildScrollView(
      physics: _isSearching ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: isSidebarExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          headerRow,
          movieContent,
        ],
      ),
    );
    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: sidebar,
        body: Stack(
          children: [
            Padding(padding: const EdgeInsets.only(top: 72.0), child: content),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () { _scaffoldKey.currentState?.openDrawer(); }),
            ),
          ],
        ),
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
