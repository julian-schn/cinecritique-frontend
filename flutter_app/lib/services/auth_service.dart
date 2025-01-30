import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_browser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class kc_params {
  static const String URL = "https://cinecritique.mi.hdm-stuttgart.de/auth";
  static const String REALM = "movie-app";
  static const String CLIENT = "movie-app-client-frontend";
  static const SCOPESL = ['profile'];
  static const String REDIRECT_URI = "http://localhost:54841/";
}

class AuthService {
  ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  ValueNotifier<UserInfo?> userInfo = ValueNotifier(null);

  late Client _client;
  late Authenticator _authenticator;
  Credential? _credential;

  Future<void> initialize() async {
    try {
      var issuer = await Issuer.discover(Uri.parse('${kc_params.URL}/realms/${kc_params.REALM}'));
      _client = Client(issuer, kc_params.CLIENT);
      _authenticator = Authenticator(_client, scopes: kc_params.SCOPESL);

      _credential = await _authenticator.credential;
      if (_credential != null) {
        userInfo.value = await _credential!.getUserInfo();
        isLoggedIn.value = true;
      }
    } catch (e) {
      print('Fehler bei der Initialisierung: $e');
    }
  }

  Future<void> login() async {
    try {
      var issuer = await Issuer.discover(Uri.parse('${kc_params.URL}/realms/${kc_params.REALM}'));
      _client = Client(issuer, kc_params.CLIENT);
      _authenticator = Authenticator(_client, scopes: kc_params.SCOPESL);
      _authenticator.authorize();
    } catch (e) {
      print('Fehler beim Login: $e');
    }
  }

  Future<void> logout() async {
    try {
      isLoggedIn.value = false;
      userInfo.value = null;
      _authenticator.logout();
    } catch (e) {
      print('Fehler beim Logout: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      _credential = await _authenticator.credential;
      if (_credential != null) {
        var tokenResponse = await _credential!.getTokenResponse();
        if (tokenResponse != null) {
          return tokenResponse.accessToken;
        }
      }
    } catch (e) {
      print('Fehler beim Token abrufen: $e');
    }
    return null;
  }

  Future<String?> getUserEmail() async {
    return userInfo.value?.email;
  }

  // ported methods from JavaScript implementation

  String getUsername() {
    if (isLoggedIn.value) {
      return userInfo.value?.name ?? 'Unknown User';
    }
    return 'User is not authenticated';
  }

  bool isAuthenticated() {
    return isLoggedIn.value;
  }

  Future<bool> updateToken([int minValidity = 5]) async {
    try {
      _credential = await _authenticator.credential;
      if (_credential != null) {
        // The OpenID client library handles token refresh automatically
        var tokenResponse = await _credential!.getTokenResponse();
        return tokenResponse != null;
      }
      return false;
    } catch (e) {
      print('Fehler beim Token aktualisieren: $e');
      login(); // Redirect to login if token refresh fails
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (!isLoggedIn.value) return null;
      
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${kc_params.URL}/realms/${kc_params.REALM}/account'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Fehler beim Abrufen des Benutzerprofils: $e');
      return null;
    }
  }

  Future<bool> updateEmail(String oldEmail, String newEmail) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${kc_params.URL}/realms/${kc_params.REALM}/account'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': newEmail,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Fehler beim Aktualisieren der E-Mail: $e');
      return false;
    }
  }

  Future<bool> deleteUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${kc_params.URL}/realms/${kc_params.REALM}/account'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await logout();
        return true;
      }
      return false;
    } catch (e) {
      print('Fehler beim Löschen des Benutzerprofils: $e');
      return false;
    }
  }
}
