import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:flutter_app/widgets/common/toggle_favorite.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/auth_service.dart'; // Importiere AuthService

class CustomSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final AuthService authService;
  final Function onSearchStart;
  final Function onSearchEnd;
  final Function(bool) onSearchResultsUpdated; // Callback für Suchergebnisse

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

  // Hier speichern wir den Hoverstatus für jeden Listeneintrag
  final Map<int, bool> _isHovered = {};

  @override
  void initState() {
    super.initState();
    // Wenn das Textfeld den Fokus verliert, schließen wir die Suchergebnisse
    // – solange nicht gerade in der Suchergebnis-Box interagiert wird.
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Kurz verzögert schließen, damit Klicks in der Suchergebnis-Box (z.B. auf das Herz) Zeit haben, verarbeitet zu werden.
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _closeSearchResults();
          }
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

    final url =
        'https://cinecritique.mi.hdm-stuttgart.de/api/movies?search=$query';

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
        // Dieser Hintergrund fängt Klicks außerhalb der Suchleiste/Ergebnisse ab.
        if (_movies.isNotEmpty)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Klick außerhalb: Suchergebnisse schließen
                FocusScope.of(context).unfocus();
                _closeSearchResults();
              },
            ),
          ),
        // Hier befinden sich die Suchleiste und Suchergebnisse – sie liegen über dem Hintergrund.
        Padding(
          padding: const EdgeInsets.only(top: 7.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 5.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Suche...',
                    hintStyle: const TextStyle(color: Colors.white),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.white),
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
                      borderSide:
                          const BorderSide(color: Colors.white, width: 1.0),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF121212),
                  ),
                  onChanged: _onSearchChanged,
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                if (_movies.isNotEmpty)
                  // Die Suchergebnisse stehen in einem Container, der
                  // in dieser Hierarchie über dem Hintergrund liegt.
                  Container(
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
                              onEnter: (_) {
                                setState(() {
                                  _isHovered[index] = true;
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  _isHovered[index] = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF121212),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8.0),
                                  title: Text(
                                    movie['title'],
                                    style: TextStyle(
                                      // Beim Hover wird der Titel rot, ansonsten weiß
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
                                    valueListenable:
                                        widget.authService.isLoggedIn,
                                    builder: (context, isLoggedIn, _) {
                                      return isLoggedIn
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20.0),
                                              child: GestureDetector(
                                                // Durch diesen GestureDetector
                                                // wird sichergestellt, dass Klicks
                                                // auf das Herz nicht von unserem
                                                // Hintergrund-GestureDetector abgefangen werden.
                                                onTap: () {
                                                  // Hier wird nur der Favoriten-Status gewechselt.
                                                  // Der FavoriteToggle selbst kümmert sich um den Toggle.
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
