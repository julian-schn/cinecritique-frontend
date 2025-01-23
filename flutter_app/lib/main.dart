import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login/login_screen.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/horizontal_movie_list.dart';
import 'package:flutter_app/widgets/widgets.dart';
import 'package:flutter_app/widgets/genre/horizontal_genre_list.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:openid_client/openid_client.dart';
import 'package:flutter_app/services/openid_io.dart'
    if (dart.library.js_interop) 'package:flutter_app/services/openid_browser.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_app/widgets/movie/moviePosterCarousel.dart'; // Importiere das neue Widget


// Global variables for authentication state
Credential? credential;
late final Client client;

// Entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize OpenID client and credentials
    client = await getClient();
    credential = await getRedirectResult(client, scopes: kc_params.SCOPESL);
  } catch (e) {
    print("Error initializing OpenID client or credentials: $e");
  }
  runApp(const MyApp());
}

// Function to initialize OpenID client
Future<Client> getClient() async {
  var uri = Uri.parse(kc_params.URL);

  if (!kIsWeb && Platform.isAndroid) uri = uri.replace(host: '10.0.2.2');
  
  var clientId = 'movieappclient';
  var issuer = await Issuer.discover(uri);
  return Client(issuer, clientId);
}

// Root widget of the application
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// State class for MyApp widget
class _MyAppState extends State<MyApp> {
  UserInfo? userInfo;

  @override
  void initState() {
    super.initState();
    _initializeUserInfo();
  }

  void _initializeUserInfo() async {
    if (credential != null) {
      try {
        final info = await credential!.getUserInfo();
        setState(() {
          userInfo = info;
        });
      } catch (e) {
        print('Error getting user info: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Updated text style
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(const Color.fromARGB(214, 255, 82, 82)), // Set the color here
          radius: const Radius.circular(10), // Optional: set rounded corners for the thumb
        ),
      ),
    );
  }
}

// Home screen widgetcs
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row( // Row to handle Sidebar and Main content horizontally
        children: [
          Sidebar(
            onHomePressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            onGenresPressed: () {
              print("Genres pressed");
            },
            onLoginPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            currentPage: 'Home',
          ),
          Expanded( // Main content area
            child: SingleChildScrollView( // Wrap the main content with SingleChildScrollView
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSearchBar(),
                  const SizedBox(height: 20),
            
                  const MoviePosterCarousel(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Row(
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
                    child: Row(
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
                   HorizontalMovieList(),
                  const SizedBox(height: 20),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
