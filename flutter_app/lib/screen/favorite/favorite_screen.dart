import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/widgets/movie/movie_card.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/favorite/favorite_controller.dart';
import 'package:flutter_app/widgets/common/search_bar.dart';
import 'package:flutter_app/screen/recommendationns/recommenndations_page.dart';
import 'package:flutter_app/screen/rating/rating_screen.dart';
import 'package:flutter_app/screen/userprofile/userprofile_screen.dart';

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
      currentPage: 'Favoriten',
    );

    final searchRow = Padding(
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
    );

    
    final headerRow = isMobile
        ? Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              children: const [
                Text(
                  'Meine Favoriten',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '.',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
              children: const [
                Text(
                  'Meine Favoriten',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '.',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 28, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );

    final cardSize = isMobile ? 180.0 : 250.0;

    final content = SingleChildScrollView(
      physics: _isSearching ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: isSidebarExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          searchRow,
          headerRow,
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (favorites.isEmpty)
            const Padding(
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
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 35.0, top: 10, bottom: 8),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: isSidebarExpanded ? 16.0 : 48.0,
                  runSpacing: 16.0,
                  children: favorites.map((movie) {
                    return SizedBox(
                      width: cardSize,
                      height: cardSize,
                      child: MovieCard(
                        posterUrl: movie['poster'] ?? '',
                        title: movie['title'] ?? 'Unbekannt',
                        imdbId: movie['imdbId'] ?? '',
                        cardWidth: cardSize,
                        cardHeight: cardSize,
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
                ),
              ),
            ),
        ],
      ),
    );

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: sidebar,
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
            sidebar,
            Expanded(child: content),
          ],
        ),
      );
    }
  }
}
