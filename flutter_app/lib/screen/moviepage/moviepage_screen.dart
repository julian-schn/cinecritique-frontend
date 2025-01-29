import 'package:flutter/material.dart';
import 'package:flutter_app/screen/moviepage/moviepage_controller.dart';
import 'package:flutter_app/widgets/common/horizontal_backdrops.dart';
import 'package:flutter_app/widgets/common/rating.dart';
import 'package:flutter_app/widgets/common/toggle_favorite.dart';
import 'package:flutter_app/widgets/common/create_rating.dart';
import 'package:flutter_app/widgets/common/show_rating.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/screen/genre/single_genre.dart';
import 'package:flutter_app/screen/login/login_screen.dart'; 
import 'package:flutter_app/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';
import 'package:flutter_app/screen/favorite/favorite_controller.dart';
import 'package:flutter_app/screen/recommendationns/recommenndations_page.dart';
import 'package:flutter_app/screen/rating/rating_screen.dart';

class MoviePage extends StatefulWidget {
  final String imdbId;
  final AuthService authService;

  const MoviePage({
    Key? key,
    required this.imdbId,
    required this.authService,
  }) : super(key: key);

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final MoviePageController _controller = MoviePageController();
  late final FavoriteController _favoriteController;
  Map<String, dynamic>? movieData;
  String? currentBackdrop;
  bool? isFavorited;

  @override
  void initState() {
    super.initState();
    _favoriteController = FavoriteController(widget.authService);
    _fetchMovieDetails();
    _checkFavoriteStatus();
  }

  Future<void> _fetchMovieDetails() async {
    final data = await _controller.fetchMovieDetails(widget.imdbId);
    setState(() {
      movieData = data;
      currentBackdrop = data?['backdrops']?.first;
    });
  }

  Future<void> _checkFavoriteStatus() async {
    final favorites = await _favoriteController.getFavorites();
    setState(() {
      isFavorited = favorites.any((movie) => movie['imdbId'] == widget.imdbId);
    });
  }

  Future<void> _launchURL(String? url) async {
    if (url != null && url.isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (await canLaunch(uri.toString())) {
        await launch(uri.toString());
      } else {
        print('Konnte die URL nicht öffnen: $url');
      }
    } else {
      print('Ungültige oder leere URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Row(
        children: [
          Sidebar(
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
                MaterialPageRoute(
                  builder: (context) => FavoriteScreen(
                    authService: widget.authService,
                  ),
                ),
              );
            },
            onReviewsPressed: () {
              print("Reviews-Seite öffnen");
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
            onProfilPressed: (){
              print("Profilseite öffnen");
            },
            onLoginPressed: () {
              widget.authService.login();
            },
            currentPage: 'Moviepage',
          ),
          Expanded(
            child: movieData == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Image.network(
                              currentBackdrop ?? 'https://via.placeholder.com/300x480',
                              width: double.infinity,
                              height: 480,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey,
                                  child: const Icon(Icons.image, color: Colors.white),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 50,
                              left: 16,
                              child: Text(
                                movieData?['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 4.0,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: DisplayRatingWidget(
                                imdbId: widget.imdbId,
                                authService: widget.authService,
                              ),
                            ),
                            Positioned(
                              right: 40,
                              bottom: 35,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 22,
                                    horizontal: 26,
                                  ),
                                ),
                                onPressed: () {
                                  final trailerUrl = movieData?['trailerLink'];
                                  _launchURL(trailerUrl);
                                },
                                child: const Text(
                                  'Watch',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            // FavoriteToggle only shown when logged in
                            Positioned(
                              right: 160,
                              bottom: 42,
                              child: ValueListenableBuilder<bool>(
                                valueListenable: widget.authService.isLoggedIn,
                                builder: (context, isLoggedIn, _) {
                                  return isLoggedIn && isFavorited != null
                                      ? FavoriteToggle(
                                          imdbId: widget.imdbId,
                                          authService: widget.authService,
                                          initiallyFavorited: isFavorited!,
                                          onToggle: (bool newState) {
                                            setState(() {
                                              isFavorited = newState;
                                            });
                                          },
                                        )
                                      : SizedBox.shrink();
                                },
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white, thickness: 2, height: 0),
                        // Genre-Buttons
                        if (movieData?['genres'] != null)
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: (movieData?['genres'] as List)
                                  .map((genre) => OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.white),
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => GenreDetailPage(genre: genre, authService: widget.authService),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          genre,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          // Backdrops
                        if (movieData?['backdrops'] != null &&
                            (movieData?['backdrops'] as List).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                height: 150,
                                width: 850,
                                child: HorizontalBackdropList(
                                  backdrops: List<String>.from(movieData?['backdrops'] ?? []),
                                  onBackdropSelected: (String backdrop) {
                                    setState(() {
                                      currentBackdrop = backdrop;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),

                        // Plot, Directed by, Released on und Cast
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    movieData?['plot'] ?? 'Keine Beschreibung verfügbar.',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 150),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        'Directed by',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: Text(
                                        movieData?['director'] ?? 'Unbekannt',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        'Released on',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      movieData?['releaseDate'] ?? 'Unbekannt',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add CreateRatingWidget and ShowRatingWidget after the backdrops section
                        ValueListenableBuilder<bool>(
                          valueListenable: widget.authService.isLoggedIn,
                          builder: (context, isLoggedIn, _) {
                            if (!isLoggedIn) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CreateRatingWidget(
                                  imdbId: widget.imdbId,
                                  authService: widget.authService,
                                  onRatingSubmitted: () {
                                    setState(() {
                                      // Refresh the reviews when a new rating is submitted
                                      _fetchMovieDetails();
                                    });
                                  },
                                ),
                                ShowRatingWidget(
                                  imdbId: widget.imdbId,
                                  authService: widget.authService,
                                ),
                              ],
                            );
                          },
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
