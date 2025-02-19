import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/screen/genre/single_genre.dart';
import 'package:flutter_app/screen/moviepage/moviepage_controller.dart';
import 'package:flutter_app/screen/rating/rating_screen.dart';
import 'package:flutter_app/screen/userprofile/userprofile_screen.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/screen/recommendationns/recommenndations_page.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';
import 'package:flutter_app/screen/favorite/favorite_controller.dart';
import 'package:flutter_app/widgets/common/horizontal_backdrops.dart';
import 'package:flutter_app/widgets/common/create_rating.dart';
import 'package:flutter_app/widgets/common/rating.dart';
import 'package:flutter_app/widgets/common/show_rating.dart';
import 'package:flutter_app/widgets/common/toggle_favorite.dart';
import 'package:url_launcher/url_launcher.dart';

class MoviePage extends StatefulWidget {
  final String imdbId;
  final AuthService authService;
  const MoviePage({Key? key, required this.imdbId, required this.authService}) : super(key: key);
  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final MoviePageController _controller = MoviePageController();
  late final FavoriteController _favoriteController;
  Map<String, dynamic>? movieData;
  String? currentBackdrop;
  bool? isFavorited;
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
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final sidebar = Sidebar(
      authService: widget.authService,
      onHomePressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(authService: widget.authService)));
      },
      onGenresPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GenrePage(authService: widget.authService)));
      },
      onFavoritesPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => FavoriteScreen(authService: widget.authService)));
      },
      onRecommendationsPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RecommendationsPage(authService: widget.authService)));
      },
      onRatingsPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RatingScreen(authService: widget.authService)));
      },
      onProfilPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UserProfileScreen(authService: widget.authService)));
      },
      onLoginPressed: () {
        widget.authService.login();
      },
      onLogoutPressed: () {
        widget.authService.logout();
      },
      currentPage: 'Moviepage',
    );

    if (movieData == null) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: sidebar,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final double headerImageHeight = isMobile ? 300 : 480;
    final double watchButtonPaddingVertical = isMobile ? 16 : 22;
    final double watchButtonPaddingHorizontal = isMobile ? 20 : 26;
    final double watchButtonFontSize = isMobile ? 16 : 18;
    final double movieCardSize = isMobile ? 180 : 250;

    Widget contentBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Image.network(
              currentBackdrop ?? 'https://via.placeholder.com/300x480',
              width: double.infinity,
              height: headerImageHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: headerImageHeight,
                  color: Colors.grey,
                  child: const Icon(Icons.image, color: Colors.white),
                );
              },
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Row(
                children: [
                  DisplayRatingWidget(averageRating: movieData?['rating'] ?? 0.0),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Positioned(
              right: isMobile ? 20 : 40,
              bottom: isMobile ? 20 : 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: watchButtonPaddingVertical, horizontal: watchButtonPaddingHorizontal),
                ),
                onPressed: () {
                  final trailerUrl = movieData?['trailerLink'];
                  _launchURL(trailerUrl);
                },
                child: Text('Watch', style: TextStyle(fontSize: watchButtonFontSize, color: Colors.white)),
              ),
            ),
            Positioned(
              right: isMobile ? 100 : 160,
              bottom: isMobile ? 20 : 42,
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
        if (movieData?['genres'] != null)
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: (movieData?['genres'] as List).map((genre) {
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => GenreDetailPage(genre: genre, authService: widget.authService)));
                  },
                  child: Text(genre, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
          ),
        if (movieData?['backdrops'] != null && (movieData?['backdrops'] as List).isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: movieCardSize,
                width: isMobile ? movieCardSize : 850,
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
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 20 : 150),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text('Directed by', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(movieData?['director'] ?? 'Unbekannt', style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text('Released on', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    Text(movieData?['releaseDate'] ?? 'Unbekannt', style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: widget.authService.isLoggedIn,
                builder: (context, isLoggedIn, _) {
                  if (!isLoggedIn) return const SizedBox.shrink();
                  return SizedBox(
                    width: isMobile ? 300 : 400,
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
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ShowRatingWidget(reviews: movieData?['reviewIds'] ?? []),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final allContent = SingleChildScrollView(child: contentBody);

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: sidebar,
        body: Stack(
          children: [
            Padding(padding: const EdgeInsets.only(top: 72.0), child: allContent),
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
            Expanded(child: allContent),
          ],
        ),
      );
    }
  }
}
