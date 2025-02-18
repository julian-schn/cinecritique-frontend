import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/widgets/common/toggle_favorite.dart';

class CustomSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final AuthService authService;
  final Function onSearchStart;
  final Function onSearchEnd;
  final Function(bool) onSearchResultsUpdated;

  const CustomSearchBar({
    Key? key,
    required this.authService,
    required this.onSearchStart,
    required this.onSearchEnd,
    required this.onSearchResultsUpdated,
  }) : super(key: key);

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = false;
  Timer? _debounce;

  // Für Hover-Effekte
  Map<int, bool> _isHovered = {};

  // Diese Variable steuert, ob gerade "innerhalb" geklickt wurde.
  bool _isClickInsideSearchResults = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      // Falls Fokus auf dem TextField verloren geht und NICHT innerhalb geklickt wurde,
      // schließen wir die Suchergebnisse.
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
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // "Debounce": Suche erst ausführen, wenn der User kurz nichts eingibt.
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchMovies(query);
    });
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

        List<Map<String, dynamic>> loadedMovies = data
            .where((movie) =>
                movie['title'] != null &&
                movie['title'].toLowerCase().contains(query.toLowerCase()))
            .map((movie) => {
                  'poster': movie['poster'] ?? '',
                  'title': movie['title'] ?? 'Unbekannt',
                  'imdbId': movie['imdbId'] ?? '',
                })
            .toList();

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Oberster GestureDetector: Wenn außerhalb geklickt wurde, schließe.
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (!_isClickInsideSearchResults) {
          FocusScope.of(context).unfocus();
          setState(() {
            _movies = [];
          });
          widget.onSearchResultsUpdated(false);
        }
        // Danach zurücksetzen, damit der nächste Klick wieder geprüft wird
        _isClickInsideSearchResults = false;
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
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                ),
                filled: true,
                fillColor: const Color(0xFF121212),
              ),
              onChanged: _onSearchChanged,
            ),
            if (_isLoading) ...[
              const SizedBox(height: 10),
              const CircularProgressIndicator(color: Colors.white),
            ],
            if (_movies.isNotEmpty)
              // Innerer GestureDetector um die Ergebnisliste
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  // Klick in den Ergebnisbereich
                  _isClickInsideSearchResults = true;
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  height: 400,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollUpdateNotification) {
                        if (_scrollController.position.pixels ==
                            _scrollController.position.maxScrollExtent) {
                          return true;
                        }
                      }
                      return false;
                    },
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
                                          movie['poster'].isNotEmpty)
                                      ? Image.network(
                                          movie['poster'],
                                          fit: BoxFit.cover,
                                        )
                                      : null,

                                  // Das entscheidende Stück:
                                  // Wir umgeben die Herz-Icon-Logik mit einem GestureDetector,
                                  // damit der Klick als "inside" erkannt wird.
                                  trailing: ValueListenableBuilder<bool>(
                                    valueListenable:
                                        widget.authService.isLoggedIn,
                                    builder: (context, isLoggedIn, _) {
                                      return isLoggedIn
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20.0),
                                              child: GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTapDown: (_) {
                                                  // -> "inside" markieren
                                                  _isClickInsideSearchResults =
                                                      true;
                                                },
                                                child: FavoriteToggle(
                                                  iconSize: 35,
                                                  imdbId: movie['imdbId'],
                                                  authService:
                                                      widget.authService,
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
              ),
          ],
        ),
      ),
    );
  }
}
