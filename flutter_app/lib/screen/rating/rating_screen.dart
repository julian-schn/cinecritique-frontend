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
    // Holt alle Reviews + Filmdetails
    _userReviewsFuture = _controller.getUserReviewsWithMovieDetails();
  }

  @override
  Widget build(BuildContext context) {
    // Prüfe, ob es sich um ein mobiles Gerät handelt (Breite < 600px)
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    // Für den Content (z. B. Layout-Anpassungen bei Sidebar-Expansion)
    final bool isSidebarExpanded = MediaQuery.of(context).size.width > 800;

    // Erstelle eine Sidebar-Instanz, die sowohl im Drawer als auch im Row genutzt werden kann
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
      currentPage: 'Bewertungen',
    );

    // Baue den Hauptinhalt (Content) der Seite
    final content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment:
              isSidebarExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            // Überschrift
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

            // Reviews laden und anzeigen
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

                final reviews = snapshot.data!;

                // Anzeige in einem Wrap
                return Wrap(
                  spacing: isSidebarExpanded ? 16.0 : 48.0,
                  runSpacing: 16.0,
                  children: reviews.map((reviewData) {
                    final imdbId = reviewData['imdbId'] ?? '';
                    final title = reviewData['movieTitle'] ?? 'Unbekannt';
                    final poster = reviewData['moviePoster'] ?? '';
                    final ratingNum = (reviewData['reviewRating'] ?? 0).toDouble();
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
                              // Poster
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
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.movie),
                                    );
                                  },
                                ),
                              ),
                              // Roter Balken unter dem Poster
                              Container(
                                height: 4,
                                color: Colors.redAccent,
                                margin: const EdgeInsets.only(bottom: 10.0),
                              ),
                              // Titel in fixem Container
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
                              // Sterne
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < ratingNum ? Icons.star : Icons.star_border,
                                    color: Colors.white,
                                    size: 23,
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                              // Review-Text
                              Container(
                                height: 60,
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
                );
              },
            ),
          ],
        ),
      ),
    );

    // Je nach Gerät: mobile Variante mit Drawer oder Desktop mit Sidebar im Row
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meine Bewertungen'),
        ),
        drawer: sidebar,
        body: content,
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
