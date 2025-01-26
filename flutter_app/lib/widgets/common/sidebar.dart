import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class Sidebar extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onHomePressed;
  final VoidCallback onGenresPressed;
  final VoidCallback onReviewsPressed;
  final VoidCallback onFavoritesPressed;
  final VoidCallback onRecommendationsPressed;
  final VoidCallback onLoginPressed;
  final String currentPage;

  const Sidebar({
    required this.authService,
    required this.onHomePressed,
    required this.onGenresPressed,
    required this.onReviewsPressed,
    required this.onFavoritesPressed,
    required this.onRecommendationsPressed,
    required this.onLoginPressed,
    required this.currentPage,
    super.key,
  });

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
  }) {
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
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.authService.isLoggedIn,
        builder: (context, isLoggedIn, _) {
          return Column(
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
              if (isLoggedIn) ...[
                buildMenuItem(
                  icon: Icons.favorite_outline,
                  title: "Favoriten",
                  onTap: widget.onFavoritesPressed,
                ),
                buildMenuItem(
                  icon: Icons.reviews_outlined,
                  title: "Reviews",
                  onTap: widget.onReviewsPressed,
                ),
                buildMenuItem(
                  icon: Icons.lightbulb_outline,
                  title: "Empfehlungen",
                  onTap: widget.onRecommendationsPressed,
                ),
              ],
              Spacer(),
              buildMenuItem(
                icon: isLoggedIn ? Icons.logout : Icons.login,
                title: isLoggedIn ? "Abmelden" : "Anmelden",
                onTap: () async {
                  if (isLoggedIn) {
                    await widget.authService.logout();
                  } else {
                    await widget.authService.login();
                  }
                },
              ),
              Align(
                alignment: isExpanded ? Alignment.centerRight : Alignment.center,
                child: IconButton(
                  icon: Icon(
                    isExpanded ? Icons.arrow_back : Icons.arrow_forward,
                    color: Colors.redAccent,
                  ),
                  onPressed: toggleSidebar,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
