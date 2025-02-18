import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';
import 'package:flutter_app/screen/recommendationns/recommenndations_page.dart';
import 'package:flutter_app/screen/userprofile/userprofile_screen.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/screen/rating/rating_controller.dart';

// Import deines MovieCard-Widgets
import 'package:flutter_app/widgets/movie/movie_card.dart';

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
  late final RatingController _controller;
  late Future<List<Map<String, dynamic>>> _userReviewsFuture;

  @override
  void initState() {
    super.initState();
    _controller = RatingController(widget.authService);
    // Neue Methode, die die Reviews + Filmdetails holt
    _userReviewsFuture = _controller.getUserReviewsWithMovieDetails();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSidebarExpanded = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar einbinden
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
                    // Titelzeile
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

                    // FutureBuilder statt ValueListenableBuilder
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _userReviewsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Fehler: ${snapshot.error}',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              '...bisher hast du noch keine Reviews geschrieben',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          );
                        }

                        final reviewList = snapshot.data!;
                        return Wrap(
                          spacing: isSidebarExpanded ? 16.0 : 48.0,
                          runSpacing: 16.0,
                          children: reviewList.map((reviewData) {
                            final imdbId = reviewData['imdbId'] ?? '';
                            final movieTitle = reviewData['movieTitle'] ?? 'Unbekannt';
                            final posterUrl = reviewData['moviePoster'] ?? '';
                            final userRating = (reviewData['reviewRating'] ?? 0).toDouble();
                            final userReview = reviewData['reviewBody'] ?? '';

                            return Container(
                              width: 240, // etwas schmaler
                              margin: const EdgeInsets.all(8.0),
                              // Wir bauen unsere Karte: zuerst das MovieCard-Widget,
                              // anschließend Sterne & Review-Text
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Bestehendes MovieCard-Widget "geschrumpft" darstellen
                                  Transform.scale(
                                    scale: 0.9, // Karte etwas kleiner skalieren
                                    child: MovieCard(
                                      posterUrl: posterUrl,
                                      title: movieTitle,
                                      imdbId: imdbId,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MoviePage(
                                              imdbId: imdbId,
                                              authService: widget.authService,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Sterne: immer 5, in Weiß
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < userRating ? Icons.star : Icons.star_border,
                                        color: Colors.white,
                                        size: 20,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 8),
                                  // Review-Text
                                  Text(
                                    userReview,
                                    style: GoogleFonts.inter(
                                      color: Colors.grey[300],
                                      fontSize: 14,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
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
