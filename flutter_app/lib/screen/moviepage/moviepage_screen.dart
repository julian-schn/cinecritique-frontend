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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(authService: widget.authService)),
        );
      },
      onGenresPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GenrePage(authService: widget.authService)),
        );
      },
      onFavoritesPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => FavoriteScreen(authService: widget.authService)),
        );
      },
      onRecommendationsPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RecommendationsPage(authService: widget.authService)),
        );
      },
      onRatingsPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RatingScreen(authService: widget.authService)),
        );
      },
      onProfilPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserProfileScreen(authService: widget.authService)),
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

    if (movieData == null) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: sidebar,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final double watchButtonPaddingVertical = isMobile ? 16 : 22;
    final double watchButtonPaddingHorizontal = isMobile ? 20 : 26;
    final double watchButtonFontSize = isMobile ? 16 : 18;
    final double heartRightMobile = 120;
    final double heartRightDesktop = 160;
    final double ratingScale = isMobile ? 0.9 : 1.0;
    final double plotFontSize = isMobile ? 14 : 16;
    final double detailLabelFontSize = isMobile ? 12 : 14;
    final double detailValueFontSize = isMobile ? 14 : 16;
    final double backdropHeight = isMobile ? 140 : 180;
    final double backdropWidth = isMobile ? MediaQuery.of(context).size.width * 0.9 : 800;

    Widget contentBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Image.network(
              currentBackdrop ?? 'https://via.placeholder.com/300x480',
              width: double.infinity,
              height: isMobile ? 300 : 480,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: isMobile ? 300 : 480,
                  color: Colors.grey,
                  child: const Icon(Icons.image, color: Colors.white),
                );
              },
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movieData?['title'] ?? '',
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Transform.scale(
                    scale: ratingScale,
                    child: DisplayRatingWidget(
                      averageRating: movieData?['rating'] ?? 0.0,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: isMobile ? 20 : 40,
              bottom: isMobile ? 20 : 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(
                    vertical: watchButtonPaddingVertical,
                    horizontal: watchButtonPaddingHorizontal,
                  ),
                ),
                onPressed: () {
                  final trailerUrl = movieData?['trailerLink'];
                  _launchURL(trailerUrl);
                },
                child: Text(
                  'Watch',
                  style: TextStyle(
                    fontSize: watchButtonFontSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              right: isMobile ? heartRightMobile : heartRightDesktop,
              bottom: isMobile ? 25 : 42,
              child: ValueListenableBuilder<bool>(
                valueListenable: widget.authService.isLoggedIn,
                builder: (context, isLoggedIn, _) {
                  return isLoggedIn && isFavorited != null
                      ? FavoriteToggle(
                          iconSize: isMobile ? 32 : 35,
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
              spacing: isMobile ? 12 : 16,
              runSpacing: isMobile ? 12 : 16,
              children: (movieData?['genres'] as List).map((genre) {
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 6 : 10,
                      horizontal: isMobile ? 12 : 18,
                    ),
                    minimumSize: Size(isMobile ? 80 : 100, isMobile ? 36 : 48),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GenreDetailPage(
                          genre: genre,
                          authService: widget.authService,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    genre,
                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16),
                  ),
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
                height: backdropHeight,
                width: backdropWidth,
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movieData?['plot'] ?? 'Keine Beschreibung verfügbar.',
                      style: TextStyle(fontSize: plotFontSize, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Directed by',
                      style: TextStyle(fontSize: detailLabelFontSize, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movieData?['director'] ?? 'Unbekannt',
                      style: TextStyle(fontSize: detailValueFontSize, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Released on',
                      style: TextStyle(fontSize: detailLabelFontSize, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movieData?['releaseDate'] ?? 'Unbekannt',
                      style: TextStyle(fontSize: detailValueFontSize, color: Colors.white),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          movieData?['plot'] ?? 'Keine Beschreibung verfügbar.',
                          style: TextStyle(fontSize: plotFontSize, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 150),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Directed by',
                            style: TextStyle(fontSize: detailLabelFontSize, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movieData?['director'] ?? 'Unbekannt',
                            style: TextStyle(fontSize: detailValueFontSize, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Released on',
                            style: TextStyle(fontSize: detailLabelFontSize, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movieData?['releaseDate'] ?? 'Unbekannt',
                            style: TextStyle(fontSize: detailValueFontSize, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: isMobile
              ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.authService.isLoggedIn,
                        builder: (context, isLoggedIn, _) {
                          if (!isLoggedIn) {
                            return const SizedBox.shrink();
                          }
                          return Transform.scale(
                            scale: 0.95,
                            child: SizedBox(
                              width: 280,
                              child: CreateRatingWidget(
                                imdbId: widget.imdbId,
                                authService: widget.authService,
                                onRatingSubmitted: () {
                                  setState(() {
                                    _fetchMovieDetails();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Transform.scale(
                        scale: 0.9,
                        child: SizedBox(
                          width: 280,
                          child: ShowRatingWidget(
                            reviews: movieData?['reviewIds'] ?? [],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: widget.authService.isLoggedIn,
                      builder: (context, isLoggedIn, _) {
                        return isLoggedIn
                            ? Transform.scale(
                                scale: 0.95,
                                child: SizedBox(
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
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.only(right: 16.0),
                      child: Transform.scale(
                        scale: 0.95,
                        child: ShowRatingWidget(
                          reviews: movieData?['reviewIds'] ?? [],
                        ),
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
            Padding(
              padding: const EdgeInsets.only(top: 72.0),
              child: allContent,
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
            Expanded(child: allContent),
          ],
        ),
      );
    }
  }
}
