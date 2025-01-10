import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login/login_screen.dart'; 
import 'package:flutter_app/screen/register/register_screen.dart';
import 'package:flutter_app/widgets/common/create_rating.dart';
import 'package:flutter_app/widgets/common/toggle_favorite.dart';
import 'package:flutter_app/widgets/widgets.dart'; 
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const MyApp());
}

//Google sign in boilerplate code, initializing Google signin with certain parameters
const List<String> scopes = <String>[
  'email',
  'profile'
];
//function to call when signing in: _googleSignIn.signIn();

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(
          onHomePressed: () {
            print("Home tapped");
          },
          onProfilePressed: () {
            print("Profile tapped");
          },
          onLoginLogoutPressed: () async {
            print("Login/Logout tapped");
          try {
            await _googleSignIn.signIn();
            // Handle successful sign in
          } catch (error) {
            // Handle sign in error
          }
          },
        ),
        body: const Column(
          children: [
            
            CustomSearchBar(),
            CreateRatingWidget(),
            FavoriteToggle(),
            Expanded(child: RegisterScreen(),
            ),
            Expanded(
              child: LoginScreen(),
             
            ),
            
          ],
        ),
      ),
    );
  }
}
