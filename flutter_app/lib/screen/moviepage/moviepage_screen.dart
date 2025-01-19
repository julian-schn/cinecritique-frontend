import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login/login_screen.dart';
import 'package:flutter_app/screen/home/home_screen.dart';
import 'package:flutter_app/widgets/common/create_rating.dart';
import 'package:flutter_app/widgets/common/toggle_favorite.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';

class MoviePageScreen extends StatelessWidget {
  const MoviePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: null,
      body: Row(
        children: [
     
          Sidebar(
            onHomePressed: () {
             Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            onGenresPressed: () {
              print("Genres gedrückt");
            },
            onLoginPressed: () {
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
               );
            },
          ),
        
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CreateRatingWidget(),
                  SizedBox(height: 20),
                  FavoriteToggle(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
