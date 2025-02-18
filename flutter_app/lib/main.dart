import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/screen/recommendationns/recommenndations_page.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/moviePosterCarousel.dart';
import 'package:flutter_app/widgets/movie/horizontal_movie_list.dart';
import 'package:flutter_app/widgets/genre/horizontal_genre_list.dart';
import 'package:flutter_app/widgets/widgets.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';
import 'package:flutter_app/screen/rating/rating_screen.dart';
import 'package:flutter_app/screen/userprofile/userprofile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.initialize();
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  const MyApp({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineCritique',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(const Color.fromARGB(214, 255, 82, 82)),
          radius: const Radius.circular(10),
        ),
      ),
      home: HomeScreen(authService: authService),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  const HomeScreen({Key? key, required this.authService}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSearching = false;

  void _navigateHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(authService: widget.authService),
      ),
    );
  }

  void _navigateGenres() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GenrePage(authService: widget.authService),
      ),
    );
  }

  void _navigateFavorites() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FavoriteScreen(authService: widget.authService),
      ),
    );
  }

  void _navigateRecommendations() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendationsPage(authService: widget.authService),
      ),
    );
  }

  void _navigateRatings() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RatingScreen(authService: widget.authService),
      ),
    );
  }

  void _navigateProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(authService: widget.authService),
      ),
    );
  }

  void _login() {
    widget.authService.login();
  }

  void _logout() {
    widget.authService.logout();
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        MoviePosterCarousel(authService: widget.authService),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Row(
            children: const [
              Text(
                'Genres',
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
        HorizontalGenreList(authService: widget.authService),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Row(
            children: const [
              Text(
                'Popular Movies',
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
        HorizontalMovieList(authService: widget.authService),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // Mobile Layout wie FavoriteScreen
      return Scaffold(
        key: _scaffoldKey,
        drawer: Sidebar(
          authService: widget.authService,
          onHomePressed: _navigateHome,
          onGenresPressed: _navigateGenres,
          onFavoritesPressed: _navigateFavorites,
          onRecommendationsPressed: _navigateRecommendations,
          onRatingsPressed: _navigateRatings,
          onProfilPressed: _navigateProfile,
          onLoginPressed: _login,
          onLogoutPressed: _logout,
          currentPage: 'Home',
        ),
        body: Stack(
          children: [
            // Inhalt nach unten verschoben, so dass das Burger-Menü Platz hat
            Padding(
              padding: const EdgeInsets.only(top: 72.0),
              child: SingleChildScrollView(
                physics: _isSearching
                    ? const NeverScrollableScrollPhysics()
                    : const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Suchleiste
                    Container(
                      color: const Color(0xFF121212),
                      padding: const EdgeInsets.only(right: 16, bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomSearchBar(
                              authService: widget.authService,
                              onSearchStart: () {
                                setState(() => _isSearching = true);
                              },
                              onSearchEnd: () {
                                setState(() => _isSearching = false);
                              },
                              onSearchResultsUpdated: (hasResults) {
                                setState(() => _isSearching = hasResults);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildContent(),
                  ],
                ),
              ),
            ),
            // Burger-Menü (Positioned, wie in FavoriteScreen)
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
      // Desktop Layout
      return Scaffold(
        body: Row(
          children: [
            Sidebar(
              authService: widget.authService,
              onHomePressed: _navigateHome,
              onGenresPressed: _navigateGenres,
              onFavoritesPressed: _navigateFavorites,
              onRecommendationsPressed: _navigateRecommendations,
              onRatingsPressed: _navigateRatings,
              onProfilPressed: _navigateProfile,
              onLoginPressed: _login,
              onLogoutPressed: _logout,
              currentPage: 'Home',
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: _isSearching
                    ? const NeverScrollableScrollPhysics()
                    : const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      color: const Color(0xFF121212),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomSearchBar(
                              authService: widget.authService,
                              onSearchStart: () {
                                setState(() => _isSearching = true);
                              },
                              onSearchEnd: () {
                                setState(() => _isSearching = false);
                              },
                              onSearchResultsUpdated: (hasResults) {
                                setState(() => _isSearching = hasResults);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
