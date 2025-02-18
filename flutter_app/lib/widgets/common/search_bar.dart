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

  // Flag, um zu kennzeichnen, dass innerhalb der Suchergebnisse interagiert wird.
  bool _isClickInsideSearchResults = false;

  final ScrollController _scrollController = ScrollController();

  // Map um den Hoverstatus für jeden Listeneintrag zu speichern.
  final Map<int, bool> _isHovered = {};

  // Overlay, das den gesamten Bildschirm abdeckt, wenn Suchergebnisse offen sind.
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && !_isClickInsideSearchResults) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && !_isClickInsideSearchResults) {
            _closeSearchResults();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Fügt das Overlay hinzu, falls noch nicht vorhanden.
  void _insertOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Klick außerhalb: Ergebnisse schließen.
          _closeSearchResults();
        },
        child: Container(),
      ),
    );
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  /// Entfernt das Overlay, falls vorhanden.
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Schließt die Suchergebnisse und entfernt ggf. das Overlay.
  void _closeSearchResults() {
    setState(() {
      _movies = [];
    });
    widget.onSearchResultsUpdated(false);
    _removeOverlay();
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

        if (_movies.isNotEmpty) _insertOverlay();
        else _removeOverlay();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (!_isClickInsideSearchResults) {
            FocusScope.of(context).unfocus();
            _closeSearchResults();
          }
        },
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
                Listener(
                  onPointerDown: (_) {
                    setState(() {
                      _isClickInsideSearchResults = true;
                    });
                  },
                  onPointerUp: (_) {
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
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  title: Text(
                                    movie['title'],
                                    style: TextStyle(
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
                                                onTapDown: (_) {
                                                  setState(() {
                                                    _isClickInsideSearchResults =
                                                        true;
                                                  });
                                                },
                                                onTapUp: (_) {
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
