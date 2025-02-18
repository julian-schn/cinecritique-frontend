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
    _userReviewsFuture = _controller.getUserReviewsWithMovieDetails();
  }

  @override
  Widget build(BuildContext context) {
    bool isSidebarExpanded = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          // ... Dein Sidebar-Code bleibt unverändert
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _userReviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Fehler: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      '...bisher hast du noch keine Reviews geschrieben',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                final movies = snapshot.data!;
                return Wrap(
                  spacing: isSidebarExpanded ? 16.0 : 48.0,
                  runSpacing: 16.0,
                  children: movies.map((movie) {
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.grey[900],
                        child: InkWell(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4.0),
                                ),
                                child: Image.network(
                                  movie['moviePoster'] ?? '',
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.movie),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie['movieTitle'] ?? 'Unknown Title',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: List.generate(
                                        movie['reviewRating'] ?? 0,
                                        (index) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      movie['reviewBody'] ?? 'No review text',
                                      style: GoogleFonts.inter(
                                        color: Colors.grey[300],
                                        fontSize: 14,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
