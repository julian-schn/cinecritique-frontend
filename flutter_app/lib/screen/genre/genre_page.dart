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
  bool _isSearching = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final bool isSidebarExpanded = MediaQuery.of(context).size.width > 800;
    
    // Responsive Schriftgrößen für Genre-Überschriften
    final double genreFontSize = isMobile ? 20 : 24;
    final double dotFontSize = isMobile ? 22 : 26;
    
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
            builder: (context) => RecommendationsPage(authService: widget.authService),
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
            builder: (context) => UserProfileScreen(authService: widget.authService),
          ),
        );
      },
      onLoginPressed: () {
        widget.authService.login();
      },
      onLogoutPressed: () {
        widget.authService.logout();
      },
      currentPage: 'Genres',
    );

    // Hauptinhalt
    Widget mainContent;
    if (isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (genres.isEmpty) {
      mainContent = const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'Keine Genres gefunden.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      );
    } else {
      mainContent = ListView.builder(
        itemCount: genres.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final genre = genres[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Column(
              crossAxisAlignment:
                  isSidebarExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      genre,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: genreFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '.',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: dotFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Übergib hier das Genre an die HorizontalMovieList
                HorizontalMovieList(
                  authService: widget.authService,
                  genre: genre, // <-- WICHTIG
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    }

    final content = SingleChildScrollView(
      physics: _isSearching
          ? const NeverScrollableScrollPhysics()
          : const ClampingScrollPhysics(),
      child: mainContent,
    );

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: sidebar,
        body: Stack(
          children: [
            // Verschiebt den Inhalt nach unten, damit das Burger-Menü oben links sichtbar bleibt
            Padding(
              padding: const EdgeInsets.only(top: 72.0),
              child: content,
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
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
            Expanded(child: content),
          ],
        ),
      );
    }
  }
}
