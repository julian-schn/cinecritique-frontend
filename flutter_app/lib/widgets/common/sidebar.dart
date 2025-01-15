import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Sidebar extends StatefulWidget {
  final VoidCallback onHomePressed;
  final VoidCallback onGenresPressed;
  final VoidCallback onLoginPressed;

  const Sidebar({
    required this.onHomePressed,
    required this.onGenresPressed,
    required this.onLoginPressed,
    super.key,
  });

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isExpanded = true;
  int selectedIndex = 0;

  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void setSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    required VoidCallback onTap,
  }) {
    bool isSelected = selectedIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setSelectedIndex(index);
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment:
                isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: isExpanded ? 16 : 0),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.redAccent : Colors.white, // Nur das Icon wird rot hervorgehoben
                  size: 24,
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                        color: Colors.white, // Der Text bleibt weiß
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
      width: isExpanded ? 250 : 100, // Eingeklappte Breite angepasst
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
            icon: Icons.home,
            title: "Home",
            index: 0,
            onTap: widget.onHomePressed,
          ),
          buildMenuItem(
            icon: Icons.category,
            title: "Genres",
            index: 1,
            onTap: widget.onGenresPressed,
          ),
          Spacer(),
          buildMenuItem(
            icon: Icons.login,
            title: "Anmelden",
            index: 2,
            onTap: widget.onLoginPressed,
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
      ),
    );
  }
}
