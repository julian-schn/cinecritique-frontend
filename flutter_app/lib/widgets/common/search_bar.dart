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

  // Flag, um interne Klicks (z. B. auf Herz oder Scrollen) zu erkennen
  bool _isClickInsideSearchResults = false; 
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Beim Verlust des Fokus wird geprüft, ob der Tap innerhalb der Ergebnisse lag.
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && !_isClickInsideSearchResults) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && !_isClickInsideSearchResults) {
            setState(() {
              _movies = [];
            });
            widget.onSearchResultsUpdated(false);
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
    super.dispose();
  }

  Future<void> _searchMovies(String query) async {
    if (query.length < 3) {
      setState(() {
        _movies = [];
      });
      widget.onSearchResultsUpdated(false);
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
        setState(() {
          _movies = [];
          _isLoading = false;
        });
        widget.onSearchResultsUpdated(false);
      }
    } catch (e) {
      print('Fehler bei der API-Anfrage: $e');
      setState(() {
        _movies = [];
        _isLoading = false;
      });
      widget.onSearchResultsUpdated(false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchMovies(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      // Der äußere GestureDetector fängt Klicks außerhalb des Suchergebnisbereichs ab.
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Wenn _isClickInsideSearchResults nicht aktiv ist, soll der Fokus entfernt und die Ergebnisse geschlossen werden.
          if (!_isClickInsideSearchResults) {
            FocusScope.of(context).unfocus();
            setState(() {
              _movies = [];
            });
            widget.onSearchResultsUpdated(false);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 5.0),
          child: Column(
            children: [
              TextField(
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
                // Der Listener sorgt dafür, dass Pointer-Events im Ergebnisbereich als "intern" gewertet werden.
                Listener(
                  onPointerDown: (_) {
                    setState(() {
                      _isClickInsideSearchResults = true;
                    });
                  },
                  onPointerUp: (_) {
                    // Hier wird der Flag sofort wieder zurückgesetzt.
                    setState(() {
                      _isClickInsideSearchResults = false;
                    });
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF121212),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  title: Text(
                                    movie['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
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
                                              padding:
                                                  const EdgeInsets.only(
                                                      right: 20.0),
                                              // Um das Verhalten gezielt zu steuern,
                                              // wird hier der FavoriteToggle in einen GestureDetector verpackt.
                                              child: GestureDetector(
                                                onTapDown: (_) {
                                                  // Während des Tap wird der Flag aktiviert.
                                                  setState(() {
                                                    _isClickInsideSearchResults =
                                                        true;
                                                  });
                                                },
                                                onTapUp: (_) {
                                                  // Nach dem Tap wird der Flag sofort wieder zurückgesetzt.
                                                  setState(() {
                                                    _isClickInsideSearchResults =
                                                        false;
                                                  });
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
