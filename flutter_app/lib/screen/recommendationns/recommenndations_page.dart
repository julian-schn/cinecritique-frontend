import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';
import 'package:flutter_app/screen/rating/rating_screen.dart';
import 'package:flutter_app/screen/recommendationns/recommendationns_controller.dart';
import 'package:flutter_app/screen/userprofile/userprofile_screen.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/movie_card.dart';

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

  // ScaffoldKey, wie in anderen Seiten
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    try {
      final movies = await _controller.fetchRecommendations(widget.authService);
      setState(() {
        recommendedMovies = movies;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Optional: Scrollfunktionen; you can keep or remove if you want
  void scrollLeft(double offset) {
    _scrollController.animateTo(
      _scrollController.offset - offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollRight(double offset) {
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final bool isSidebarExpanded = MediaQuery.of(context).size.width > 800;

    final double headerFontSize = isMobile ? 20.0 : 26.0;
    final double dotFontSize = isMobile ? 22.0 : 28.0;

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
          MaterialPageRoute(
            builder: (context) => RecommendationsPage(authService: widget.authService),
          ),
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
      currentPage: 'Empfehlungen',
    );

    // Header row
    final headerRow = Padding(
      padding: isMobile
          ? const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0)
          : EdgeInsets.only(
              left: isSidebarExpanded
                  ? 20.0
                  : (MediaQuery.of(context).size.width - 1060) / 2,
              right: 35.0,
              top: 85.0,
              bottom: 8,
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Empfehlungen',
            style: TextStyle(
              color: Colors.white,
              fontSize: headerFontSize,
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
    );

    final content = Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerRow,
          const SizedBox(height: 14),
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
            Container(
              height: isMobile ? 180 : 250,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20.0 : 50.0),
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
                          cardWidth: isMobile ? 180 : 250,
                          cardHeight: isMobile ? 180 : 250,
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
                  Positioned(
                    left: 0,
                    top: (isMobile ? 180 : 250) / 2 -
                        (isMobile ? 45.0 : 65.0) / 2,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _scrollController.animateTo(
                          _scrollController.offset -
                              (isMobile ? 200 : 400),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        child: Icon(
                          Icons.arrow_left,
                          size: isMobile ? 45.0 : 65.0,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: (isMobile ? 180 : 250) / 2 -
                        (isMobile ? 45.0 : 65.0) / 2,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _scrollController.animateTo(
                          _scrollController.offset +
                              (isMobile ? 200 : 400),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        child: Icon(
                          Icons.arrow_right,
                          size: isMobile ? 45.0 : 65.0,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    final mainContent = SingleChildScrollView(child: content);

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: sidebar,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 72.0),
              child: mainContent,
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
            Expanded(child: mainContent),
          ],
        ),
      );
    }
  }
}
