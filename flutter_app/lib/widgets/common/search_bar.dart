import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:flutter_app/widgets/common/toggle_favorite.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/auth_service.dart';

class CustomSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final AuthService authService;
  final Function onSearchStart;
  final Function onSearchEnd;
  final Function(bool) onSearchResultsUpdated;

  const CustomSearchBar({
    super.key,
    required this.authService,
    required this.onSearchStart,
    required this.onSearchEnd,
    required this.onSearchResultsUpdated,
  });

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = false;
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  // Hover-Status für jeden Listeneintrag
  final Map<int, bool> _isHovered = {};

  @override
  void initState() {
    super.initState();
    // Sobald das Textfeld den Fokus verliert, Liste schließen (nach kurzer Verzögerung).
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _closeSearchResults();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchMovies(String query) async {
    if (query.length < 3) {
      _closeSearchResults();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = 'https://cinecritique.mi.hdm-stuttgart.de/api/movies?search=$query';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        List<Map<String, dynamic>> loadedMovies = data.where((movie) {
          return movie['title'] != null &&
              movie['title'].toLowerCase().contains(query.toLowerCase());
        }).map((movie) {
          return {
            'poster': movie['poster'] ?? '',
            'title': movie['title'] ?? 'Unbekannt',
            'imdbId': movie['imdbId'] ?? '',
          };
        }).toList();

        setState(() {
          _movies = loadedMovies;
          _isLoading = false;
        });
        widget.onSearchResultsUpdated(_movies.isNotEmpty);
      } else {
        print('Fehler: ${response.statusCode}');
        _closeSearchResults();
      }
    } catch (e) {
      print('Fehler bei der API-Anfrage: $e');
      _closeSearchResults();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchMovies(query);
    });
  }

  void _closeSearchResults() {
    if (mounted) {
      setState(() {
        _movies = [];
      });
      widget.onSearchResultsUpdated(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1) Hintergrund, der nur aktiv ist, wenn es Ergebnisse gibt:
        if (_movies.isNotEmpty)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Klick irgendwo außerhalb => schließen
                FocusScope.of(context).unfocus();
                _closeSearchResults();
              },
            ),
          ),

        // 2) Der sichtbare Bereich mit der SearchBar + Ergebnisliste
        Column(
          children: [
            // Die eigentliche Suchzeile
            Padding(
              padding: const EdgeInsets.only(top: 7.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 5.0),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Suche...',
                    hintStyle: const TextStyle(color: Colors.white),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white, width: 1.0),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF121212),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            ),

            // Ladeindikator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Ergebnisliste (wenn vorhanden)
            if (_movies.isNotEmpty)
              // 3) Ergebnisliste in einem GestureDetector, damit Klicks hier NICHT
              //    den Hintergrund erreichen und zum Schließen führen.
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // Leerer onTap, wir wollen nur verhindern, dass Klicks "durchfallen".
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  height: 400,
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _movies.length,
                    itemBuilder: (context, index) {
                      final movie = _movies[index];
                      return Column(
                        children: [
                          MouseRegion(
                            onEnter: (_) => setState(() => _isHovered[index] = true),
                            onExit: (_) => setState(() => _isHovered[index] = false),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF121212),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                                title: Text(
                                  movie['title'],
                                  style: TextStyle(
                                    // Rot beim Hover, sonst weiß
                                    color: _isHovered[index] == true
                                        ? Colors.redAccent
                                        : Colors.white,
                                  ),
                                ),
                                leading: (movie['poster'] != null &&
                                        movie['poster'].toString().isNotEmpty)
                                    ? Image.network(
                                        movie['poster'],
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                trailing: ValueListenableBuilder<bool>(
                                  valueListenable: widget.authService.isLoggedIn,
                                  builder: (context, isLoggedIn, _) {
                                    return isLoggedIn
                                        ? Padding(
                                            padding: const EdgeInsets.only(right: 20.0),
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                // Klick auf Herz => NICHT schließen
                                                // FavoriteToggle kümmert sich intern um den Toggle.
                                              },
                                              child: FavoriteToggle(
                                                iconSize: 35,
                                                imdbId: movie['imdbId'],
                                                authService: widget.authService,
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink();
                                  },
                                ),
                                onTap: () {
                                  // Klick auf den Film => Navigation (Details)
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
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
