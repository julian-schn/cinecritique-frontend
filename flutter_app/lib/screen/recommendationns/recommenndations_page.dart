import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/screen/recommendationns/recommendationns_controller.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/movie_card.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';
import 'package:flutter_app/screen/rating/rating_screen.dart';
import 'package:flutter_app/screen/userprofile/userprofile_screen.dart';

class RecommendationsPage extends StatefulWidget {
  final AuthService authService;

  const RecommendationsPage({Key? key, required this.authService})
      : super(key: key);

  @override
  _RecommendationsPageState createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  final RecommendationsController _controller = RecommendationsController();
  List<Map<String, dynamic>> recommendedMovies = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('Initializing recommendations page...');
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    print('Fetching recommendations...');
    try {
      final movies = await _controller.fetchRecommendations(widget.authService);
      print('Received recommendations: ${movies.length} movies');
      print('Recommended movies:');
      for (var movie in movies) {
        print('- ${movie['title']} (${movie['imdbId']})');
      }
      setState(() {
        recommendedMovies = movies;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching recommendations: $e');
      print('Stack trace: ${StackTrace.current}');
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
    // Prüfe, ob es sich um ein mobiles Gerät handelt (z. B. Breite < 600px)
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    // Erstelle die Sidebar-Instanz
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
            builder: (context) =>
                FavoriteScreen(authService: widget.authService),
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
      currentPage: 'Empfehlungen',
    );

    // Hauptinhalt der Seite
    final content = Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titel
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              children: const [
                Text(
                  'Empfehlungen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '.',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Inhalt: Ladeanzeige, leere Liste oder horizontale Liste der empfohlenen Filme
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (recommendedMovies.isEmpty)
            const Center(
              child: Text(
                'No recommendations found.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            )
          else
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendedMovies.length,
                      itemBuilder: (context, index) {
                        final movie = recommendedMovies[index];
                        return MovieCard(
                          posterUrl: movie['poster'] ?? '',
                          title: movie['title'] ?? 'Unknown',
                          imdbId: movie['imdbId'] ?? '',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MoviePage(
                                  imdbId: movie['imdbId'] ?? '',
                                  authService: widget.authService,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  if (recommendedMovies.isNotEmpty) ...[
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
                ],
              ),
            ),
        ],
      ),
    );

    // Responsive Darstellung: Bei mobilen Geräten Sidebar als Drawer, ansonsten als fester Bereich links
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Empfehlungen'),
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
