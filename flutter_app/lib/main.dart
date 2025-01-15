import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login/login_screen.dart';
import 'package:flutter_app/widgets/common/custom_app_bar.dart';
import 'package:flutter_app/widgets/widgets.dart'; 
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

const List<String> scopes = <String>[
  'email',
  'profile'
];

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      
      if (account != null) {
        account.authentication.then((GoogleSignInAuthentication auth) {
          print('Access Token: ${auth.accessToken}');
        }).catchError((error) {
          print('Authentication error: $error');
        });
      }
    });
    
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: CustomAppBar(
          onHomePressed: () {
            print("Home tapped");
          },
          onProfilePressed: () {
            print("Profile tapped");
          },
          onLoginLogoutPressed: () async {
            try {
              if (_currentUser == null) {
                await _googleSignIn.signIn();
              } else {
                await _googleSignIn.signOut();
              }
            } catch (error) {
              print('Sign in/out error: $error');
            }
          },
        ),
        body: Column(
          children: [
            const CustomSearchBar(),
            // Correct way to do conditional rendering
            if (_currentUser != null)
              Column(
                children: const [
                  Text('Welcome back!'),
                  // Add your authenticated user widgets here
                ],
              )
            else
              Column(
                children: const [
                  LoginScreen(),
                  // Add your non-authenticated user widgets here
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}