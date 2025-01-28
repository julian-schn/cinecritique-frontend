import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';

class FavoriteToggle extends StatefulWidget {
  const FavoriteToggle({
    super.key,
    this.iconSize = 40,
    required this.imdbId,
    required this.authService,
    this.initiallyFavorited = false,
    this.onToggle,
  });

  final double iconSize;
  final String imdbId;
  final AuthService authService;
  final bool initiallyFavorited;
  final Function(bool)? onToggle;

  @override
  _FavoriteToggleState createState() => _FavoriteToggleState();
}

class _FavoriteToggleState extends State<FavoriteToggle> {
  late bool isFavorited;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isFavorited = widget.initiallyFavorited;
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (!widget.authService.isLoggedIn.value) {
      setState(() {
        isFavorited = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final favorites = await widget.authService.getFavorites();
      if (mounted) {
        setState(() {
          isFavorited = favorites.any((movie) => movie['imdbId'] == widget.imdbId);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Fehler beim Laden der Favoriten',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF1C1C1C),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> toggleFavorite() async {
    if (isLoading) return;

    if (!widget.authService.isLoggedIn.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bitte melde dich an, um Favoriten zu speichern',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF1C1C1C),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      bool success;
      final bool wasAlreadyFavorited = isFavorited;

      if (wasAlreadyFavorited) {
        success = await widget.authService.removeFavorite(widget.imdbId);
      } else {
        success = await widget.authService.addFavorite(widget.imdbId);
      }

      if (success && mounted) {
        setState(() {
          isFavorited = !wasAlreadyFavorited;
          if (widget.onToggle != null) {
            widget.onToggle!(isFavorited);
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorited ? 'Film zu Favoriten hinzugefügt' : 'Film aus Favoriten entfernt',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1C1C1C),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        // Bei Fehler den Status zurücksetzen
        setState(() {
          isFavorited = wasAlreadyFavorited;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Fehler beim Aktualisieren der Favoriten',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF1C1C1C),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Fehler beim Aktualisieren der Favoriten',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF1C1C1C),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.authService.isLoggedIn,
      builder: (context, isLoggedIn, child) {
        return GestureDetector(
          onTap: toggleFavorite,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.redAccent : Colors.white,
                size: widget.iconSize,
              ),
              if (isLoading)
                SizedBox(
                  width: widget.iconSize * 0.8,
                  height: widget.iconSize * 0.8,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              if (!isLoading && !isFavorited)
                Positioned(
                  bottom: 11 * (widget.iconSize / 40),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18 * (widget.iconSize / 40),
                  ),
                ),
              if (!isLoading && isFavorited)
                Positioned(
                  bottom: 11 * (widget.iconSize / 40),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18 * (widget.iconSize / 40),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
