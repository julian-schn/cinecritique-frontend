import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login/login_screen.dart';
import 'package:flutter_app/widgets/common/custom_app_bar.dart';
import 'package:flutter_app/widgets/widgets.dart'; 
import 'package:google_sign_in/google_sign_in.dart';

// The main function is the entry point of your Flutter application
void main() {
  // Ensure Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// Define Google Sign In scopes at the top level for better organization
const List<String> scopes = <String>[
  'email',
  'profile'
];

// Create a single instance of GoogleSignIn to be used throughout the app
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Track the current user's sign-in status
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    
    // Listen for changes in user authentication status
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      
      // If we have a user, get their authentication token
      if (account != null) {
        account.authentication.then((GoogleSignInAuthentication auth) {
          print('Access Token: ${auth.accessToken}');
          // Here you would typically send this token to your backend
        }).catchError((error) {
          print('Authentication error: $error');
        });
      }
    });
    
    // Try to sign in silently on startup
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Add other theme configurations as needed
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
                // User is not signed in, so sign them in
                await _googleSignIn.signIn();
              } else {
                // User is signed in, so sign them out
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
            // Your commented widgets can be conditionally rendered based on auth state
            if (_currentUser != null) ...[
              // Widgets to show when user is signed in
            ] else [
              // Widgets to show when user is signed out
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any resources when the widget is disposed
    super.dispose();
  }
}