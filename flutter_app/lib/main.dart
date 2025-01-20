import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login/login_screen.dart';
import 'package:flutter_app/screen/moviepage/moviepage_screen.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/widgets/movie/horizontal_movie_list.dart';
import 'package:flutter_app/widgets/widgets.dart';
import 'package:flutter_app/widgets/genre/horizontal_genre_list.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:openid_client/openid_client.dart';
// Conditional import for platform-specific OpenID implementation
import 'package:flutter_app/services/openid_io.dart'
    if (dart.library.js_interop) 'package:flutter_app/services/openid_browser.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

// Global variables for authentication state
// credential might be null if user is not authenticated
Credential? credential;
// client will be initialized before app runs (marked as late)
late final Client client;

// Entry point of the application
void main() async {
  // Ensure Flutter bindings are initialized for async operations
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize OpenID client
  client = await getClient();
  // Attempt to get credentials from redirect (for OAuth flow)
  credential = await getRedirectResult(client, scopes: kc_params.SCOPESL);
  // Start the application
  runApp(const MyApp());
}

// Function to initialize OpenID client
Future<Client> getClient() async {
  // Parse the authentication server URL
  var uri = Uri.parse(kc_params.URL);
  // Special handling for Android emulator
  if (!kIsWeb && Platform.isAndroid) uri = uri.replace(host: '10.0.2.2');
  // Client ID for the application
  var clientId = 'movieappclient';

  // Discover OpenID configuration from the server
  var issuer = await Issuer.discover(uri);
  return Client(issuer, clientId);
}

// Root widget of the application
class MyApp extends StatefulWidget {
  // Constructor with required key parameter
  const MyApp({super.key});

  @override
  // Create the mutable state for this widget
  State<MyApp> createState() => _MyAppState();
}

// State class for MyApp widget
class _MyAppState extends State<MyApp> {
  // Store user information after authentication
  UserInfo? userInfo;

  @override
  // Called when this widget is first inserted into the tree
  void initState() {
    super.initState();
    _initializeUserInfo();
  }

  // Method to fetch user information if credentials exist
  void _initializeUserInfo() async {
    if (credential != null) {
      try {
        // Attempt to get user information using the credential
        final info = await credential!.getUserInfo();
        // Update the state with the new user information
        setState(() {
          userInfo = info;
        });
      } catch (e) {
        print('Error getting user info: $e');
      }
    }
  }

  @override
  // Build method defines the widget tree
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // Remove debug banner
      home: HomeScreen(),  // Set initial screen
      theme: ThemeData(
        // Set dark theme background color
        scaffoldBackgroundColor: Color(0xFF121212),
      ),
    );
  }
}

// Home screen widget showing the main content
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar navigation component
          Sidebar(
            // Navigation handler for home button
            onHomePressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            // Handler for genres button
            onGenresPressed: () {
              print("Genres gedrückt");
            },
            // Navigation handler for login button
            onLoginPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          // Main content area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search component at the top
                CustomSearchBar(),
                const SizedBox(height: 20),
                // Categories section header
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
                      // Decorative dot after the header
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
                // Horizontal scrolling list of genres
                const HorizontalGenreList(),
                const SizedBox(height: 20),
                // Popular movies section header
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
                      // Decorative dot after the header
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
                // Horizontal scrolling list of movies
                const HorizontalMovieList(),
                const SizedBox(height: 20),
                // Navigation button to movie page
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MoviePageScreen()),
                      );
                    },
                    child: Text('Zur Movie Page'),
                  ),
                ),
                // Spacer to push content to the top
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}