import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/genre/genre_page.dart';
import 'package:flutter_app/screen/userprofile/userprofile_controller.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/widgets/common/sidebar.dart';
import 'package:flutter_app/screen/favorite/favorite_screen.dart';
import 'package:flutter_app/screen/recommendationns/recommenndations_page.dart';
import 'package:flutter_app/screen/rating/rating_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfileScreen extends StatefulWidget {
  final AuthService authService;

  const UserProfileScreen({
    Key? key,
    required this.authService,
  }) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserProfileController _controller;
  Map<String, String>? _userInfo;
  bool _isLoading = true;
  String? _editingField;
  String? _newEmail;
  String? _alertMessage;
  String? _alertType;
  bool _showDeleteModal = false;
  final TextEditingController _emailController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controller = UserProfileController(widget.authService);
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      if (!widget.authService.isAuthenticated()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(authService: widget.authService),
          ),
        );
        return;
      }
      final userInfo = await _controller.getUserInfo();
      final profile = await widget.authService.getUserProfile();
      setState(() {
        _userInfo = userInfo;
        if (profile != null) {
          _userInfo?.addAll({
            'name': (profile['firstName'] ?? '') + ' ' + (profile['lastName'] ?? ''),
            'username': profile['username'] ?? '',
          });
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user info: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAlert(String message, String type) {
    setState(() {
      _alertMessage = message;
      _alertType = type;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _alertMessage = null;
          _alertType = null;
        });
      }
    });
  }

  Future<void> _handleEmailUpdate() async {
    if (_newEmail == null || _newEmail!.isEmpty) return;
    try {
      final currentEmail = _userInfo?['email'];
      if (currentEmail == null) return;
      final success = await widget.authService.updateEmail(currentEmail, _newEmail!);
      if (success) {
        setState(() {
          _userInfo?['email'] = _newEmail!;
          _editingField = null;
        });
        _showAlert('Email erfolgreich geändert.', 'success');
      } else {
        _showAlert('Fehler beim Ändern der E-Mail Adresse', 'error');
      }
    } catch (e) {
      _showAlert('Fehler beim Ändern der E-Mail Adresse', 'error');
    }
  }

  Future<void> _handleDeleteProfile() async {
    _showAlert('Du hast dein Profil erfolgreich gelöscht.', 'success');
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final success = await widget.authService.deleteUserProfile();
      if (success) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(authService: widget.authService),
            ),
          );
        }
      } else {
        _showAlert('Fehler beim Löschen des Profils.', 'error');
      }
    } catch (e) {
      _showAlert('Fehler beim Löschen des Profils.', 'error');
    }
  }

  Widget _buildProfileField(String label, String value, {bool canEdit = false}) {
    final isEditing = _editingField == label.toLowerCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isEditing
                      ? TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            _newEmail = value;
                            _handleEmailUpdate();
                          },
                        )
                      : Text(
                          value,
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
              if (canEdit)
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (isEditing) {
                        _editingField = null;
                      } else {
                        _editingField = label.toLowerCase();
                        _emailController.text = value;
                      }
                    });
                  },
                  child: Text(
                    isEditing ? 'Speichern' : 'ändern',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: TextButton(
        onPressed: () => setState(() => _showDeleteModal = true),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.red[400]),
            const SizedBox(width: 8),
            Text(
              'Profil löschen',
              style: TextStyle(color: Colors.red[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteConfirmationDialog() {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text(
        'Profil löschen',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Möchtest du dein Profil wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _showDeleteModal = false),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () {
            setState(() => _showDeleteModal = false);
            _handleDeleteProfile();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Löschen'),
        ),
      ],
    );
  }

  Widget _buildAlert() {
    if (_alertMessage == null) return const SizedBox.shrink();
    final backgroundColor = _alertType == 'success' ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        border: Border.all(color: backgroundColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _alertMessage!,
        style: TextStyle(color: backgroundColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    final sidebar = Sidebar(
      authService: widget.authService,
      onHomePressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(authService: widget.authService)),
        );
      },
      onGenresPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GenrePage(authService: widget.authService)),
        );
      },
      onFavoritesPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FavoriteScreen(authService: widget.authService)),
        );
      },
      onRecommendationsPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RecommendationsPage(authService: widget.authService)),
        );
      },
      onRatingsPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RatingScreen(authService: widget.authService)),
        );
      },
      onProfilPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen(authService: widget.authService)),
        );
      },
      onLoginPressed: () {
        widget.authService.login();
      },
      onLogoutPressed: () {
        widget.authService.logout();
      },
      currentPage: 'Profil',
    );

    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header without burger menu here – burger menu will be shown as positioned element
                  Row(
                    children: const [
                      Text(
                        'Profil Einstellungen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '.',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileField(
                          'Dein Name',
                          _userInfo?['name'] ?? 'Not available',
                        ),
                        _buildProfileField(
                          'Dein Username',
                          _userInfo?['username'] ?? 'Not available',
                        ),
                        _buildProfileField(
                          'Email Adresse',
                          _userInfo?['email'] ?? 'Not available',
                          canEdit: true,
                        ),
                        _buildDeleteButton(),
                        _buildAlert(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: sidebar,
        body: Stack(
          children: [
            content,
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _showDeleteModal ? _buildDeleteConfirmationDialog() : null,
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            sidebar,
            Expanded(child: content),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _showDeleteModal ? _buildDeleteConfirmationDialog() : null,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
