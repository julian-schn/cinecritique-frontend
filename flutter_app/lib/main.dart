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

  // AuthService initialisieren
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
          thumbColor:
              MaterialStateProperty.all(const Color.fromARGB(214, 255, 82, 82)),
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
  bool _isSearching = false; // Zustand für die Suche

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CustomSearchBar
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: CustomSearchBar(
            authService: widget.authService,
            onSearchStart: () {
              setState(() {
                _isSearching = true; // Suche gestartet
              });
            },
            onSearchEnd: () {
              setState(() {
                _isSearching = false; // Suche beendet
              });
            },
            onSearchResultsUpdated: (hasResults) {
              setState(() {
                _isSearching = hasResults;
              });
            },
          ),
        ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('CineCritique'),
        // Bei mobilen Geräten wird automatisch das Hamburger-Icon angezeigt, wenn ein Drawer vorhanden ist
      ),
      // Bei mobilen Geräten Sidebar als Drawer nutzen
      drawer: isMobile
          ? Sidebar(
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
              currentPage: 'Home',
            )
          : null,
      body: isMobile
          // Mobile: Content wird als ScrollView angezeigt (Drawer wird über die AppBar geöffnet)
          ? SingleChildScrollView(
              physics: _isSearching ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
              child: _buildContent(),
            )
          // Desktop/Tablet: Sidebar links, Content rechts
          : Row(
              children: [
                Sidebar(
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
                  currentPage: 'Home',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: _isSearching ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
    );
  }
}
