import 'package:flutter_app/services/auth_service.dart';

class UserProfileController {
  final AuthService _authService;

  UserProfileController(this._authService);

  Future<Map<String, String>> getUserInfo() async {
    final email = await _authService.getUserEmail();
    final username = email?.split('@').first ?? 'Unknown User';
    
    return {
      'email': email ?? 'Not available',
      'username': username,
    };
  }
}
