import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login/login_screen.dart'; 
import 'package:flutter_app/screen/register/register_screen.dart';
import 'package:flutter_app/widgets/common/create_rating.dart';
import 'package:flutter_app/widgets/common/toggle_favorite.dart';
import 'package:flutter_app/widgets/widgets.dart'; 

void main() {
  runApp(const MyApp());
}

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
          onLoginLogoutPressed: () {
            print("Login/Logout tapped");
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
