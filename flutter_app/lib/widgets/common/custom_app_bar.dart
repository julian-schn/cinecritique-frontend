//appbar or navbar to be implemented here
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

//Google sign in initialization
const List<String> scopes = <String>[
  'email',
  'profile'
];
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onHomePressed;
  final VoidCallback onProfilePressed;
  final VoidCallback onLoginLogoutPressed;

  const CustomAppBar({
    super.key,
    required this.onHomePressed,
    required this.onProfilePressed,
    required this.onLoginLogoutPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onHomePressed,
            child: const Text('Home'),
          ),
          GestureDetector(
            onTap: onProfilePressed,
            child: const Text('Profile'),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onLoginLogoutPressed,
          icon: const Icon(Icons.login),
        ),
      ],
    );
  }
}

