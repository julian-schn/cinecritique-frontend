import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/services/auth_service.dart';

void _login() async {
  final loginUrl = '${kc_params.URL}/realms/${kc_params.realm}/protocol/openid-connect/auth?'
      'client_id=${kc_params.CLIENT}&'
      'redirect_uri=${Uri.encodeComponent('https://cinecritique.mi.hdm-stuttgart.de/callback')}&' //add flutter url here
      'response_type=code&'
      'scope=openid';

  try {
    await launch(loginUrl, forceWebView: true);
  } catch (e) {
    print('Error launching login URL: $e');
  }
}

class Sidebar extends StatefulWidget {
  final VoidCallback onHomePressed;
  final VoidCallback onGenresPressed;
  final VoidCallback onLoginPressed;
  final String currentPage; // Hier den aktuellen Bildschirm als Parameter hinzufügen

  const Sidebar({
    required this.onHomePressed,
    required this.onGenresPressed,
    required this.onLoginPressed,
    required this.currentPage, // Übergib den aktuellen Bildschirm als Parameter
    super.key,
  });

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isExpanded = true;

  // Funktion zum Umschalten der Sidebar
  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  // Funktion zum Erstellen eines Menüpunktes
  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    // Hervorhebung, wenn der Titel dem aktuellen Bildschirm entspricht
    bool isSelected = widget.currentPage == title;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment:
                isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: isExpanded ? 24 : 0),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.redAccent : Colors.white,
                  size: 24,
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: EdgeInsets.only(left: 32),
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: isExpanded ? 250 : 100, 
      color: Color(0xFF121212),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: isExpanded ? "CineCritique" : "CC",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ".",
                        style: GoogleFonts.inter(
                          color: Colors.redAccent,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          buildMenuItem(
            icon: Icons.home_outlined,
            title: "Home",
            onTap: widget.onHomePressed,
          ),
          buildMenuItem(
            icon: Icons.category_outlined,
            title: "Genres",
            onTap: widget.onGenresPressed,
          ),
          buildMenuItem(
            icon: Icons.favorite_outline,
            title: "Favoriten",
            onTap: widget.onGenresPressed,
          ),
          buildMenuItem(
            icon: Icons.reviews_outlined,
            title: "Reviews",
            onTap: widget.onGenresPressed,
          ),
          buildMenuItem(
            icon: Icons.lightbulb_outline,
            title: "Empfehlungen",
            onTap: widget.onGenresPressed,
          ),
          buildMenuItem(
            icon: Icons.account_circle_outlined,
            title: "Profil",
            onTap: widget.onGenresPressed,
          ),
          Spacer(), 
          buildMenuItem(
            icon: Icons.logout,
            title: "Abmelden",
            onTap: _login,
          ),
          Align(
            alignment: isExpanded ? Alignment.centerRight : Alignment.center,
            child: IconButton(
              icon: Icon(
                isExpanded ? Icons.arrow_back : Icons.arrow_forward,
                color: Colors.redAccent,
              ),
              onPressed: _login, 
            ),
          ),
        ],
      ),
    );
  }
}
