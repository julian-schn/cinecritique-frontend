import 'package:flutter/material.dart';

class CreateRatingWidget extends StatefulWidget {
  const CreateRatingWidget({super.key});

  @override
  _CreateRatingWidgetState createState() => _CreateRatingWidgetState();
}

class _CreateRatingWidgetState extends State<CreateRatingWidget> {
  int _rating = 0;  
  int _hoverRating = 0;  
  TextEditingController _textController = TextEditingController();

  void _setRating(int index) {
    setState(() {
      if (_rating == index + 1) {
        // Stern wird zurückgesetzt beim klicken
        _rating = 0;
      } else {
        _rating = index + 1; // angeklickten Stern
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
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0), // Abstand zwischen den Sternen 
              child:  GestureDetector(
                onTap: () => _setRating(index), // Klick-Tap um Bewertung zu setzen oder zurückzusetzen
                onPanUpdate: (details) {
                  setState(() {
                    // Touch-Bewegung
                    if (details.localPosition.dx > (index * 40)) {
                      _hoverRating = index + 1;  // Dynamische Bewertung durch Touch
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
                      _hoverRating = 0; // setzt hover zurück beim draufklicken
                    });
                  },
                  child: Icon(
                    index < (_hoverRating > 0 ? _hoverRating : _rating)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),
          Container(
            constraints: BoxConstraints(maxWidth: 300), 
            child: TextField(
              controller: _textController,
              maxLength: 150,
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Deine Bewertung',
                counterText: "${_textController.text.length}/150", 
              ),
              onChanged: (_) {
                setState(() {
                });
              },
            ),
          ),
          const SizedBox(height: 2),
          ElevatedButton(
            onPressed: () {
              // hier logik für Button
            },
            child: const Text('Bewertung absenden',
            style: TextStyle(
            color: Colors.black)
            ),
          ),
        ],
      ),
    );
  }
}
