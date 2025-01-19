import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login/login_screen.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/horizontal_movie_list.dart';
import 'package:flutter_app/widgets/widgets.dart';
import 'package:flutter_app/widgets/genre/horizontal_genre_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Entfernt den roten Debug-Flyer
      home: HomeScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF121212), // Hintergrundfarbe für alle
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,  
              children: [
                CustomSearchBar(),
                const SizedBox(height: 20),  
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Row(  // Verwende Row für horizontale Anordnung
              children: [
                 Text(
                     'Categories',
                   style: TextStyle(
                   color: Colors.white,
                    fontSize: 24,
                     fontWeight: FontWeight.bold,
                    ),
                    ),
                  Text(
                   '.',
                    style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    ),
                 ),
               ],
               ),
                ),
                const HorizontalGenreList(), 


                const SizedBox(height: 20),  
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Row(  // Verwende Row für horizontale Anordnung
              children: [
                 Text(
                     'Popular Movies',
                   style: TextStyle(
                   color: Colors.white,
                    fontSize: 24,
                     fontWeight: FontWeight.bold,
                    ),
                    ),
                  Text(
                   '.',
                    style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    ),
                 ),
               ],
               ),
                ),
                const HorizontalMovieList(), 
                const SizedBox(height: 20),
                Center(  
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MoviePageScreen()),
                      );
                    },
                    child: Text('Zur Movie Page'),
                  ),
                ),
                const Spacer(),  
              ],
            ),
          ),
        ],
      ),
    );
  }
}
