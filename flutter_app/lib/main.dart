import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login/login_screen.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart'; 

import 'package:flutter_app/widgets/common/sidebar.dart'; 
import 'package:flutter_app/widgets/widgets.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false, // Entfernt den roten Debug-Flyer
      home: HomeScreen(), 
      // hintergrundfarbe für alle
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF121212),
        
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
              children: [
                CustomSearchBar(),
                
                
                ElevatedButton(
                  // testweise button bis movie da ist
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MoviePageScreen()),
                    );
                  },
                  child: Text('Zur Movie Page'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
