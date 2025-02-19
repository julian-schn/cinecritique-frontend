import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/screen/recommendationns/recommenndations_page.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/common/search_bar.dart';
import 'package:flutter_app/widgets/movie/movie_card.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/screen/favorite/favorite_controller.dart';
import 'package:flutter_app/screen/rating/rating_screen.dart';
import 'package:flutter_app/screen/userprofile/userprofile_screen.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';

class FavoriteScreen extends StatefulWidget {
  final AuthService authService;
  const FavoriteScreen({Key? key, required this.authService}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;
  late final FavoriteController _controller;
  bool _isSearching = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controller = FavoriteController(widget.authService);
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() {
      isLoading = true;
    });
    final favList = await _controller.getFavorites();
    setState(() {
      favorites = favList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final bool isSidebarExpanded = MediaQuery.of(context).size.width > 800;

    // Verwende hier die gleichen Padding- und Schriftwerte wie in der HomeScreen
    final EdgeInsets headerPadding = EdgeInsets.only(
      left: isSidebarExpanded ? 20.0 : (MediaQuery.of(context).size.width - 1060) / 2,
      right: 35.0,
      top: 85.0,
      bottom: 8,
    );
    final TextStyle headerTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
    final TextStyle headerDotStyle = const TextStyle(
      color: Colors.redAccent,
      fontSize: 26,
      fontWeight: FontWeight.bold,
    );

    // Definiere die Kartengrößen genau wie in deiner HorizontalMovieList:
    final double cardWidth = isMobile ? 200 : 250;
    final double cardHeight = isMobile ? 200 : 250;

    // Favoriten-Inhalt: Verwende ein Wrap, sodass die MovieCards responsiv nebeneinander angeordnet werden.
    Widget favoritesContent;
    if (isLoading) {
      favoritesContent = const Center(child: CircularProgressIndicator());
    } else if (favorites.isEmpty) {
      favoritesContent = const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'Keine Favoriten vorhanden.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      );
    } else {
      favoritesContent = Wrap(
        alignment: WrapAlignment.center,
        spacing: 16.0,
        runSpacing: 16.0,
        children: favorites.map((movie) {
          return SizedBox(
            width: cardWidth,
            height: cardHeight,
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
          );
        }).toList(),
      );
    }

    final Widget content = SingleChildScrollView(
      physics: _isSearching
          ? const NeverScrollableScrollPhysics()
          : const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment:
            isSidebarExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Suchleiste
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Row(
              children: [
                Expanded(
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
              ],
            ),
          ),
          // Überschrift "Meine Favoriten"
          Padding(
            padding: headerPadding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Meine Favoriten', style: headerTextStyle),
                Text('.', style: headerDotStyle),
              ],
            ),
          ),
          // Favoriten-Grid (Wrap)
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 35.0, top: 10, bottom: 1),
            child: favoritesContent,
          ),
        ],
      ),
    );

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: Sidebar(
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
          currentPage: 'Favoriten',
        ),
        body: Stack(
          children: [
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
              currentPage: 'Favoriten',
            ),
            Expanded(child: content),
          ],
        ),
      );
    }
  }
}
