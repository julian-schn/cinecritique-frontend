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

  // Hier speichern wir unsere gefundenen Filme
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = false;
  Timer? _debounce;

  // Für Hover-Effekte (wenn Du sie brauchst)
  Map<int, bool> _isHovered = {};

  // ScrollController für die Liste
  final ScrollController _scrollController = ScrollController();

  // KEY für den Container mit den Suchergebnissen
  final GlobalKey _resultsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
   
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        
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
        final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
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
      // Mit onTapDown bekommst Du die Details der Position
      onTapDown: (TapDownDetails details) {
        // 1) Falls keine Suchergebnisse angezeigt werden, muss man nichts schließen
        if (_movies.isEmpty) return;

        // 2) Versuche die Position des Results-Containers zu ermitteln
        final box = _resultsKey.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final offset = box.localToGlobal(Offset.zero);
          final size = box.size;
          // Erzeugt ein Rechteck (links oben = offset, Breite+Höhe = size)
          final rect = offset & size;

          // 3) Prüfen, ob der Klick "innerhalb" liegt
          if (!rect.contains(details.globalPosition)) {
            // -> Klick außerhalb => Suchergebnisse schließen
            FocusScope.of(context).unfocus(); // Tastatur / Fokus weg
            setState(() {
              _movies = [];
            });
            widget.onSearchResultsUpdated(false);
          }
        }
      },
      behavior: HitTestBehavior.translucent,
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
              Container(
               
                key: _resultsKey,
                padding: const EdgeInsets.all(8.0),
                height: 400,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    // Beliebiges Scrollverhalten, hier z.B. um unendlich zu laden
                    if (scrollNotification is ScrollUpdateNotification) {
                      if (_scrollController.position.pixels ==
                          _scrollController.position.maxScrollExtent) {
                        // TODO: ggf. neue Seite laden ...
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
                                trailing: ValueListenableBuilder<bool>(
                                  valueListenable:
                                      widget.authService.isLoggedIn,
                                  builder: (context, isLoggedIn, _) {
                                    return isLoggedIn
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20.0),
                                            child: FavoriteToggle(
                                              iconSize: 35,
                                              imdbId: movie['imdbId'],
                                              authService: widget.authService,
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
    );
  }
}
