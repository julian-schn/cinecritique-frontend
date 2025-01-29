import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/screen/rating/rating_controller.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/movie_card.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';
import 'package:flutter_app/screen/recommendationns/recommenndations_page.dart';
import 'package:flutter_app/widgets/common/search_bar.dart';

class RatingScreen extends StatefulWidget {
  final AuthService authService;

  const RatingScreen({
    Key? key,
    required this.authService,
  }) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  late final RatingController _controller;
  List<Map<String, dynamic>> ratedMovies = [];
  bool isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    print('RatingScreen: Initializing state');
    _controller = RatingController(widget.authService);
    loadRatedMovies();
  }

  Future<void> loadRatedMovies() async {
    print('RatingScreen: Loading rated movies');
    setState(() {
      isLoading = true;
    });

    try {
      final movies = await _controller.getRatedMovies(widget.authService);
      print('RatingScreen: Loaded ${movies.length} rated movies');
      setState(() {
        ratedMovies = movies;
        isLoading = false;
      });
    } catch (e) {
      print('RatingScreen: Error loading rated movies: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSidebarExpanded = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            authService: widget.authService,
            currentPage: 'Bewertungen',
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
                MaterialPageRoute(
                  builder: (context) => FavoriteScreen(
                    authService: widget.authService,
                  ),
                ),
              );
            },
            onRecommendationsPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RecommendationsPage(
                    authService: widget.authService,
                  ),
                ),
              );
            },
            onRatingsPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RatingScreen(
                    authService: widget.authService,
                  ),
                ),
              );
            },
            onProfilPressed: () {
              print("Profile page not implemented yet");
            },
            onLoginPressed: () {
              widget.authService.login();
            },
            onLogoutPressed: () {
              widget.authService.logout();
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: _isSearching
                  ? NeverScrollableScrollPhysics()
                  : ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: isSidebarExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: CustomSearchBar(
                      authService: widget.authService,
                      onSearchStart: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                      onSearchEnd: () {
                        setState(() {
                          _isSearching = false;
                        });
                      },
                      onSearchResultsUpdated: (hasResults) {
                        setState(() {
                          _isSearching = hasResults;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: isSidebarExpanded ? 20.0 : (MediaQuery.of(context).size.width - 1060) / 2,
                      right: 35.0,
                      top: 85.0,
                      bottom: 8
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Meine Bewertungen',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '.',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (ratedMovies.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Keine Bewertungen vorhanden.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 35.0, top: 10, bottom: 1),
                      child: Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: isSidebarExpanded ? 16.0 : 48.0,
                          runSpacing: 16.0,
                          children: ratedMovies.map((movie) => Container(
                            width: 250,
                            height: 250,
                            child: Stack(
                              children: [
                                MovieCard(
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
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${movie['rating']}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
