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
import 'package:flutter_app/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';
import 'package:flutter_app/screen/favorite/favorite_controller.dart';
import 'package:flutter_app/screen/recommendationns/recommenndations_page.dart';
import 'package:flutter_app/screen/rating/rating_screen.dart';
import 'package:flutter_app/screen/userprofile/userprofile_screen.dart';
import 'package:flutter_app/services/rating_service.dart';

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

  // GlobalKey zum Öffnen des Drawer (wird nur auf mobilen Geräten genutzt)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    // Prüfe, ob es sich um ein mobiles Gerät handelt (Breite < 600px)
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
      currentPage: 'Moviepage',
    );

    // Hauptinhalt der MoviePage
    final content = movieData == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Das Header-Element als Stack mit dem Hintergrundbild
                Stack(
                  children: [
                    Image.network(
                      currentBackdrop ?? 'https://via.placeholder.com/300x480',
                      width: double.infinity,
                      height: 480,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 480,
                          color: Colors.grey,
                          child: const Icon(Icons.image, color: Colors.white),
                        );
                      },
                    ),
                    // Überschrift + (bei mobilen Geräten) Burger-Icon
                    Positioned(
                      bottom: 50,
                      left: 16,
                      right: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isMobile)
                            IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                            ),
                          if (isMobile) const SizedBox(width: 8),
                          Flexible(
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Weitere Positioned-Elemente (z. B. Rating, Trailer-Button, FavoriteToggle)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Row(
                        children: [
                          DisplayRatingWidget(
                            averageRating: movieData?['rating'] ?? 0.0,
                          ),
                          const SizedBox(width: 24),
                        ],
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
                              : const SizedBox.shrink();
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
                                      builder: (context) => GenreDetailPage(
                                          genre: genre,
                                          authService: widget.authService),
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
                            movieData?['plot'] ??
                                'Keine Beschreibung verfügbar.',
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
                // Rating-Section (CreateRatingWidget und ShowRatingWidget)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CreateRatingWidget (nur wenn eingeloggt)
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.authService.isLoggedIn,
                        builder: (context, isLoggedIn, _) {
                          if (!isLoggedIn) return const SizedBox.shrink();
                          return SizedBox(
                            width: 400,
                            child: CreateRatingWidget(
                              imdbId: widget.imdbId,
                              authService: widget.authService,
                              onRatingSubmitted: () {
                                setState(() {
                                  _fetchMovieDetails();
                                });
                              },
                            ),
                          );
                        },
                      ),
                      // ShowRatingWidget
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ShowRatingWidget(
                            reviews: movieData?['reviewIds'] ?? [],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

    // Responsive Darstellung:
    // Auf mobilen Geräten: Scaffold ohne AppBar – stattdessen wird der Burger-Button in der Überschrift (im Stack) genutzt.
    // Auf Desktop: Sidebar links, Content rechts.
    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
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

// Beispiel für die ReviewsList (unverändert)
class ReviewsList extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;
  final RatingService ratingService;

  const ReviewsList({
    Key? key,
    required this.reviews,
    required this.ratingService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Reviews',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No reviews yet'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ratingService.formatUsername(review['createdBy'] ?? 'Anonymous'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: List.generate(
                              review['rating'] ?? 0,
                              (index) => const Icon(Icons.star, color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(review['body'] ?? 'No comment'),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
