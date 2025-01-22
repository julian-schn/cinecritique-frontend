import 'package:flutter/material.dart';

class CreateRatingWidget extends StatefulWidget {
  const CreateRatingWidget({super.key});

  @override
  _CreateRatingWidgetState createState() => _CreateRatingWidgetState();
}

class _CreateRatingWidgetState extends State<CreateRatingWidget> {
  int _rating = 0;
  int _hoverRating = 0;
  final TextEditingController _textController = TextEditingController();

  void _setRating(int index) {
    setState(() {
      if (_rating == index + 1) {
        _rating = 0;
      } else {
        _rating = index + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
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
                      }
                    });
                  },
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _hoverRating = index + 1;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _hoverRating = 0;
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
            constraints: BoxConstraints(maxWidth: 400),
            child: TextField(
              controller: _textController,
              maxLength: 150,
              maxLines: 5, // Textfeldhöhe anpassen
              decoration: InputDecoration(
                labelText: 'Deine Bewertung',
                labelStyle: TextStyle(color: Colors.white),
                counterText: "${_textController.text.length}/150",
                counterStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                filled: true,
                fillColor: Color(0xFF121212),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 30.0, // Höhe des Textfelds
                  horizontal: 24.0, // Abstand zum Rand
                ),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 2),
          ElevatedButton(
            onPressed: () {
              // Hier Logik für Button hinzufügen
            },
            child: const Text(
              'Bewertung absenden',
              style: TextStyle(
                color: Color(0xFF121212), // Schriftfarbe des Buttons
              ),
            ),
          ),
        ],
      ),
    );
  }
}
