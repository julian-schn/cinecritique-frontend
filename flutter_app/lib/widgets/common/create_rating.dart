import 'package:flutter/material.dart';
import 'package:flutter_app/services/rating_service.dart';
import 'package:flutter_app/services/auth_service.dart';

class CreateRatingWidget extends StatefulWidget {
  final String imdbId;
  final AuthService authService;
  final Function? onRatingSubmitted;

  const CreateRatingWidget({
    Key? key,
    required this.imdbId,
    required this.authService,
    this.onRatingSubmitted,
  }) : super(key: key);

  @override
  _CreateRatingWidgetState createState() => _CreateRatingWidgetState();
}

class _CreateRatingWidgetState extends State<CreateRatingWidget> {
  int _rating = 0;
  int _hoverRating = 0;
  final TextEditingController _textController = TextEditingController();
  late final RatingService _ratingService;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    print('CreateRatingWidget: Initializing state for movie ID: ${widget.imdbId}');
    _ratingService = RatingService(widget.authService);
  }

  void _setRating(int index) {
    print('CreateRatingWidget: Setting rating to ${index + 1}');
    setState(() {
      if (_rating == index + 1) {
        _rating = 0;
        print('CreateRatingWidget: Rating cleared (was ${index + 1})');
      } else {
        _rating = index + 1;
        print('CreateRatingWidget: Rating set to $_rating');
      }
    });
  }

  Future<void> _submitRating() async {
    print('CreateRatingWidget: Starting rating submission');
    print('CreateRatingWidget: Current rating: $_rating');
    print('CreateRatingWidget: Review text length: ${_textController.text.length}');

    if (_rating == 0) {
      print('CreateRatingWidget: Submission failed - no rating selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wähle eine Bewertung aus (1-5 Sterne).')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    print('CreateRatingWidget: Set submission state to true');

    try {
      print('CreateRatingWidget: Attempting to create review');
      final success = await _ratingService.createReview(
        widget.imdbId,
        _textController.text.trim(),
        _rating,
      );

      if (success) {
        print('CreateRatingWidget: Review created successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bewertung erfolgreich erstellt!')),
        );
        _textController.clear();
        setState(() {
          _rating = 0;
        });
        print('CreateRatingWidget: Cleared form after successful submission');
        widget.onRatingSubmitted?.call();
        print('CreateRatingWidget: Called onRatingSubmitted callback');
      } else {
        print('CreateRatingWidget: Failed to create review');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Erstellen der Bewertung.')),
        );
      }
    } catch (e, stackTrace) {
      print('CreateRatingWidget: Error during review submission: $e');
      print('CreateRatingWidget: Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ein unerwarteter Fehler ist aufgetreten.')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
      print('CreateRatingWidget: Set submission state to false');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('CreateRatingWidget: Building widget, current rating: $_rating, hover rating: $_hoverRating');
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bewertung',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => _setRating(index),
                  onPanUpdate: (details) {
                    setState(() {
                      if (details.localPosition.dx > (index * 40)) {
                        _hoverRating = index + 1;
                        print('CreateRatingWidget: Pan update - hover rating set to $_hoverRating');
                      }
                    });
                  },
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _hoverRating = index + 1;
                        print('CreateRatingWidget: Mouse enter - hover rating set to $_hoverRating');
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _hoverRating = 0;
                        print('CreateRatingWidget: Mouse exit - hover rating cleared');
                      });
                    },
                    child: Transform.scale(
                      scale: _hoverRating == index + 1 ? 1.2 : 1.0,
                      child: Icon(
                        index < (_hoverRating > 0 ? _hoverRating : _rating)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              controller: _textController,
              maxLength: 150,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Deine Bewertung',
                labelStyle: const TextStyle(color: Colors.white),
                counterText: "${_textController.text.length}/150",
                counterStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFF121212),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 24.0,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (_) {
                setState(() {
                  print('CreateRatingWidget: Review text updated, length: ${_textController.text.length}');
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRating,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF121212)),
                    ),
                  )
                : const Text(
                    'Bewertung absenden',
                    style: TextStyle(
                      color: Color(0xFF121212),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('CreateRatingWidget: Disposing widget');
    _textController.dispose();
    super.dispose();
  }
}