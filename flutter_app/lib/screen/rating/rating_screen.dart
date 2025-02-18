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

class RatingScreen extends StatefulWidget {
  final AuthService authService;
  const RatingScreen({Key? key, required this.authService}) : super(key: key);

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
    _userReviewsFuture = _controller.getUserReviewsWithMovieDetails();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSidebarExpanded = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
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
            currentPage: 'Bewertungen',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    isSidebarExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
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
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _userReviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              'Fehler: ${snapshot.error}',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              '...bisher hast du noch keine Reviews geschrieben',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        );
                      }

                      final reviews = snapshot.data!;

                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          right: 35.0,
                          top: 10,
                          bottom: 1,
                        ),
                        child: Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: isSidebarExpanded ? 16.0 : 48.0,
                            runSpacing: 16.0,
                            children: reviews.map((reviewData) {
                              final imdbId = reviewData['imdbId'] ?? '';
                              final title = reviewData['movieTitle'] ?? 'Unbekannt';
                              final poster = reviewData['moviePoster'] ?? '';
                              final ratingNum =
                                  (reviewData['reviewRating'] ?? 0).toDouble();
                              final reviewText = reviewData['reviewBody'] ?? '';

                              return Container(
                                width: 250,
                                margin: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: const Color(0xFF1C1C1C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12.0),
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12.0),
                                            topRight: Radius.circular(12.0),
                                          ),
                                          child: Image.network(
                                            poster,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: 200,
                                                color: Colors.grey[800],
                                                child: const Icon(Icons.movie),
                                              );
                                            },
                                          ),
                                        ),
                                        Container(
                                          height: 4,
                                          color: Colors.redAccent,
                                          margin: const EdgeInsets.only(bottom: 10.0),
                                        ),
                                        Container(
                                          height: 48,
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          alignment: Alignment.topCenter,
                                          child: Text(
                                            title,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < ratingNum
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.white,
                                              size: 23,
                                            );
                                          }),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          height: 62,
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          alignment: Alignment.topCenter,
                                          child: Text(
                                            reviewText,
                                            style: GoogleFonts.inter(
                                              color: Colors.grey[300],
                                              fontSize: 14,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
