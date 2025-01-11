import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/register/register_screen.dart'; 
import 'package:flutter_app/widgets/common/sidebar.dart'; 

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white, 
                    ),
                    textAlign: TextAlign.center, 
                  ),
                  const SizedBox(height: 32), 
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'E-Mail-Adresse',
                      labelStyle: TextStyle(color: Colors.white), 
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0), 
                       ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0), 
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0), 
                      ),
                    ),
                    style: TextStyle(color: Colors.white), 
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Passwort',
                      labelStyle: TextStyle(color: Colors.white), 
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0), 
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0), 
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0), 
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                     
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, 
                      side: BorderSide(color: Colors.white, width: 1.0), 
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF121212), 
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, 
                      side: BorderSide(color: Colors.white, width: 1.0), 
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Color(0xFF121212), 
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
