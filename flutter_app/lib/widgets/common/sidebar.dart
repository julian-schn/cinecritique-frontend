import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';

class Sidebar extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onHomePressed;
  final VoidCallback onGenresPressed;
  final VoidCallback onFavoritesPressed;
  final VoidCallback onRecommendationsPressed;
  final VoidCallback onRatingsPressed;
  final VoidCallback onProfilPressed;
  final VoidCallback onLoginPressed;
  final VoidCallback onLogoutPressed;
  final String currentPage;

  const Sidebar({
    Key? key,
    required this.authService,
    required this.onHomePressed,
    required this.onGenresPressed,
    required this.onFavoritesPressed,
    required this.onRecommendationsPressed,
    required this.onRatingsPressed,
    required this.onProfilPressed,
    required this.onLoginPressed,
    required this.onLogoutPressed,
    required this.currentPage,
  }) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isExpanded = true;

  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? Colors.white : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey,
        ),
      ),
      onTap: onTap,
      selected: selected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExpanded ? 200 : 60,
      color: const Color(0xFF121212),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.menu, color: Colors.white),
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
          const Divider(color: Colors.white),
          Expanded(
            child: ListView(
              children: [
                buildMenuItem(
                  icon: Icons.home,
                  title: "Home",
                  onTap: widget.onHomePressed,
                  selected: widget.currentPage == 'Home',
                ),
                buildMenuItem(
                  icon: Icons.movie,
                  title: "Genres",
                  onTap: widget.onGenresPressed,
                  selected: widget.currentPage == 'Genres',
                ),
                buildMenuItem(
                  icon: Icons.favorite,
                  title: "Favoriten",
                  onTap: widget.onFavoritesPressed,
                  selected: widget.currentPage == 'Favoriten',
                ),
                buildMenuItem(
                  icon: Icons.star,
                  title: "Bewertungen",
                  onTap: widget.onRatingsPressed,
                  selected: widget.currentPage == 'Bewertungen',
                ),
                buildMenuItem(
                  icon: Icons.recommend,
                  title: "Empfehlungen",
                  onTap: widget.onRecommendationsPressed,
                  selected: widget.currentPage == 'Empfehlungen',
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: widget.authService.isLoggedIn,
                  builder: (context, isLoggedIn, _) {
                    return isLoggedIn
                        ? buildMenuItem(
                            icon: Icons.person,
                            title: "Profil",
                            onTap: widget.onProfilPressed,
                            selected: widget.currentPage == 'Profil',
                          )
                        : buildMenuItem(
                            icon: Icons.login,
                            title: "Login",
                            onTap: widget.onLoginPressed,
                            selected: widget.currentPage == 'Login',
                          );
                  },
                ),
                buildMenuItem(
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: widget.onLogoutPressed,
                  selected: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
