import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/moviePosterCarousel.dart';
import 'package:flutter_app/widgets/movie/horizontal_movie_list.dart';
import 'package:flutter_app/widgets/genre/horizontal_genre_list.dart';
import 'package:flutter_app/widgets/widgets.dart';

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
      title: 'Movie App',
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

class HomeScreen extends StatelessWidget {
  final AuthService authService;

  const HomeScreen({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            authService: authService,
            onHomePressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(authService: authService)),
              );
            },
            onGenresPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GenrePage(authService: authService)),
              );
            },
            onFavoritesPressed: () {
              print("Favoriten-Seite öffnen");
            },
            onReviewsPressed: () {
              print("Reviews-Seite öffnen");
            },
            onRecommendationsPressed: () {
              print("Empfehlungen-Seite öffnen");
            },
            // Hier den Login-Button so anpassen, dass er die Login-Methode aufruft:
            onLoginPressed: () {
              authService.login(); // Die Login-Methode des AuthService aufrufen
            },
            currentPage: 'Home',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hier die CustomSearchBar hinzufügen
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: CustomSearchBar(authService: authService),
                  ),
                  const SizedBox(height: 20),

                  
                  const SizedBox(height: 20),
                  MoviePosterCarousel(authService: authService),
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
                  HorizontalGenreList(authService: authService),
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
                  HorizontalMovieList(authService: authService),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
