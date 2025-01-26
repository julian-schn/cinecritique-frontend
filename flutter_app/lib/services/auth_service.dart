import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_browser.dart';

class kc_params {
  static const String URL = "https://cinecritique.mi.hdm-stuttgart.de/auth"; // Keycloak Server-URL
  static const String REALM = "movie-app";
  static const String CLIENT = "movie-app-client-frontend";
  static const SCOPESL = ['profile'];
}

class AuthService {
  ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  ValueNotifier<UserInfo?> userInfo = ValueNotifier(null);

  late Client _client;
  late Authenticator _authenticator;

  // Keycloak Client initialisieren
  Future<void> initialize() async {
    try {
      var issuer = await Issuer.discover(Uri.parse('${kc_params.URL}/realms/${kc_params.REALM}'));
      _client = Client(issuer, kc_params.CLIENT);
      _authenticator = Authenticator(_client, scopes: kc_params.SCOPESL);

      // Redirect-Ergebnis prüfen
      var credential = await _authenticator.credential;
      if (credential != null) {
        userInfo.value = await credential.getUserInfo();
        isLoggedIn.value = true;
      }
    } catch (e) {
      print('Fehler bei der Initialisierung: $e');
    }
  }

  // Login-Funktion
  Future<void> login() async {
    try {
       var issuer = await Issuer.discover(Uri.parse('${kc_params.URL}/realms/${kc_params.REALM}'));
      _client = Client(issuer, kc_params.CLIENT);
            _authenticator = Authenticator(_client, scopes: kc_params.SCOPESL);

      _authenticator.authorize(); // Umleitung zu Keycloak-Login
    } catch (e) {
      print('Fehler beim Login: $e');
    }
  }

  // Logout-Funktion
  Future<void> logout() async {
    try {
      isLoggedIn.value = false;
      userInfo.value = null;
      _authenticator.logout();
    } catch (e) {
      print('Fehler beim Logout: $e');
    }
  }
}
