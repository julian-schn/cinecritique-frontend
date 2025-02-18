import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Alias für AuthService, damit es nicht zu Konflikten kommt
import 'package:flutter_app/services/auth_service.dart' as auth;
// Alias für MoviePage, damit es nicht zu Konflikten kommt
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart' as movie_page;

class FavoriteToggle extends StatelessWidget {
  final double iconSize;
  final String imdbId;
  final auth.AuthService authService;
  const FavoriteToggle({super.key, required this.iconSize, required this.imdbId, required this.authService});

  @override
  Widget build(BuildContext context) {
    // Einfach ein Icon zum Testen
    return Icon(Icons.favorite_border, size: iconSize, color: Colors.white);
  }
}

class CustomSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final auth.AuthService authService;
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

  // Hoverstatus für jeden Listeneintrag
  final Map<int, bool> _isHovered = {};

  // GlobalKey, um die Größe/Position der Ergebnisliste zu ermitteln
  final GlobalKey _resultsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
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
        final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        final loadedMovies = data.where((movie) {
          final title = (movie['title'] ?? '').toString().toLowerCase();
          return title.contains(query.toLowerCase());
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        if (_movies.isEmpty) return;

        final tapPosition = details.globalPosition;
        final renderBox = _resultsKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final boxOffset = renderBox.localToGlobal(Offset.zero);
          final boxSize = renderBox.size;
          final inLeft = tapPosition.dx >= boxOffset.dx;
          final inRight = tapPosition.dx <= boxOffset.dx + boxSize.width;
          final inTop = tapPosition.dy >= boxOffset.dy;
          final inBottom = tapPosition.dy <= boxOffset.dy + boxSize.height;
          final insideBox = inLeft && inRight && inTop && inBottom;
          if (!insideBox) {
            FocusScope.of(context).unfocus();
            _closeSearchResults();
          }
        } else {
          FocusScope.of(context).unfocus();
          _closeSearchResults();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Suchleiste
          Container(
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

          // Ergebnisliste
          if (_movies.isNotEmpty)
            Container(
              key: _resultsKey,
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
                                color: _isHovered[index] == true ? Colors.redAccent : Colors.white,
                              ),
                            ),
                            leading: (movie['poster'] != null && movie['poster'].toString().isNotEmpty)
                                ? Image.network(movie['poster'], fit: BoxFit.cover)
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
                                            // Klick aufs Herz => NICHT schließen.
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => movie_page.MoviePage(
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
    );
  }
}
