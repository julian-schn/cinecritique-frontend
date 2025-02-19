class User {
  final String id;
  final String username;
  final String email;

  User({required this.id, required this.username, required this.email});

//TODO: Hook up to keycloak

  factory User.fromIdToken(Map<String, dynamic> idTokenClaims) {
    return User(
      id: idTokenClaims['sub'],
      username: idTokenClaims['preferred_username'],
      email: idTokenClaims['email'],
    );
  }
}