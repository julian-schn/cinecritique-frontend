import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/moviepage/moviepage_controller.dart';
import 'package:flutter_app/widgets/common/horizontal_backdrops.dart';
import 'package:flutter_app/widgets/common/rating.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:url_launcher/url_launcher.dart';

class MoviePage extends StatefulWidget {
  final String imdbId;
  const MoviePage({
    Key? key,
    required this.imdbId
  }) : super(key: key);

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final MoviePageController _controller = MoviePageController();
  Map<String, dynamic>? movieData;
  String? currentBackdrop;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  Future<void> _fetchMovieDetails() async {
    final data = await _controller.fetchMovieDetails(widget.imdbId);
    setState(() {
      movieData = data;
      currentBackdrop = data?['backdrops']?.first;
    });
  }

  Future<void> _launchURL(String? url) async {
    if (url != null && url.isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (await canLaunch(uri.toString())) {
        await launch(uri.toString());
      } else {
        print('Konnte die URL nicht öffnen: $url');
      }
    } else {
      print('Ungültige oder leere URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Row(
        children: [
          Sidebar(
            onHomePressed: () {
              // Hier zur MainPage navigieren
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            onGenresPressed: () {
              print("Genres gedrückt");
            },
            onLoginPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            currentPage: 'Movie',
          ),
          Expanded(
            child: movieData == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            // Hauptbild - verwendet nun currentBackdrop
                            Image.network(
                              currentBackdrop ?? 'https://via.placeholder.com/300x480',
                              width: double.infinity,
                              height: 480,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey,
                                  child: const Icon(Icons.image, color: Colors.white),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 50,
                              left: 16,
                              child: Text(
                                movieData?['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 4.0,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: DisplayRatingWidget(
                                averageRating: movieData?['rating'] ?? 0.0,
                              ),
                            ),
                            Positioned(
                              right: 40,
                              bottom: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 22,
                                    horizontal: 26,
                                  ),
                                ),
                                onPressed: () {
                                  final trailerUrl = movieData?['trailerLink'];
                                  _launchURL(trailerUrl);
                                },
                                child: const Text(
                                  'Watch',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white, thickness: 2, height: 0),
                        if (movieData?['genres'] != null)
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: (movieData?['genres'] as List)
                                  .map((genre) => OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.white),
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          print('Genre $genre gedrückt');
                                        },
                                        child: Text(
                                          genre,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        if (movieData?['backdrops'] != null &&
                            (movieData?['backdrops'] as List).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                height: 150,
                                width: 850,
                                child: HorizontalBackdropList(
                                  backdrops: List<String>.from(movieData?['backdrops'] ?? []),
                                  onBackdropSelected: (String backdrop) {
                                    setState(() {
                                      currentBackdrop = backdrop;  // Aktualisiert das Hauptbild
                                    });
                                  },
                                ),
                              ),
                            ),
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