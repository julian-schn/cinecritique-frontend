import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/services/user_service.dart';
import 'package:flutter_app/services/movie_service.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/movie_card.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';
import 'package:flutter_app/screen/recommendationns/recommenndations_page.dart';
import 'package:flutter_app/screen/userprofile/userprofile_screen.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class RatingScreen extends StatefulWidget {
  final AuthService authService;

  const RatingScreen({
    Key? key,
    required this.authService,
  }) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;
  late final UserService _userService;
  late final MovieService _movieService;

  @override
  void initState() {
    super.initState();
    _userService = UserService(widget.authService);
    _movieService = MovieService(widget.authService);
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    try {
      final userMe = await _userService.getUserMe();
      final ratedMovieIds = await _userService.getRatedMovies(userMe);

      // Fetch all movies in parallel
      final moviesData = await Future.wait(
        ratedMovieIds.map((imdbId) => _movieService.getMovie(imdbId)),
      );

      setState(() {
        _movies.clear();
        _movies.addAll(moviesData);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSidebarExpanded = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            authService: widget.authService,
            onHomePressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    authService: widget.authService,
                  ),
                ),
              );
            },
            onGenresPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GenrePage(
                    authService: widget.authService,
                  ),
                ),
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
              // Already on ratings page
            },
            onProfilPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    authService: widget.authService,
                  ),
                ),
              );
            },
            onLoginPressed: () {
              widget.authService.login();
            },
            onLogoutPressed: () {
              widget.authService.logout();
            },
            currentPage: 'Bewertungen',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Meine Bewertungen',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '.',
                          style: GoogleFonts.inter(
                            color: Colors.redAccent,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _movies.isEmpty
                            ? Center(
                                child: Text(
                                  '...bisher hast du noch keine Reviews geschrieben',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            : Wrap(
                                spacing: isSidebarExpanded ? 16.0 : 48.0,
                                runSpacing: 16.0,
                                children: _movies.map((movie) {
                                  return SizedBox(
                                    width: 250,
                                    height: 250,
                                    child: MovieCard(
                                      posterUrl: movie['poster'] ?? '',
                                      title: movie['title'] ?? 'Unknown',
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
                              ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
