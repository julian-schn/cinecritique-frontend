import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/screen/recommendationns/recommendationns_controller.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/horizontal_movie_list.dart';

class RecommendationsPage extends StatefulWidget {
  final AuthService authService;

  const RecommendationsPage({Key? key, required this.authService}) : super(key: key);

  @override
  _RecommendationsPageState createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  final RecommendationsController _controller = RecommendationsController();
  List<Map<String, dynamic>> recommendedMovies = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

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
      print('Error fetching recommendations: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            authService: widget.authService,
            onHomePressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(authService: widget.authService)),
              );
            },
            onGenresPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GenrePage(authService: widget.authService)),
              );
            },
            onFavoritesPressed: () {
              print("Open favorites page");
            },
            onReviewsPressed: () {
              print("Open reviews page");
            },
            onRecommendationsPressed: () {
              // We're already on the recommendations page
            },
            onProfilPressed: () {
              print("Open profile page");
            },
            onLoginPressed: () {
              widget.authService.login();
            },
            currentPage: 'Empfehlungen',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : recommendedMovies.isEmpty
                      ? const Center(
                          child: Text(
                            'No recommendations found.',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: recommendedMovies.length,
                          itemBuilder: (context, index) {
                            final movie = recommendedMovies[index];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        movie['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        '.',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  HorizontalMovieList(
                                    genre: 'recommendations',
                                    authService: widget.authService,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
