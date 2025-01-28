import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_browser.dart';
import 'dart:html';
import 'package:url_launcher/url_launcher.dart';
import 'package:openid_client/openid_client_browser.dart';

class kc_params {
  static const String URL =
      "http://cinecritique.mi.hdm-stuttgart.de/auth"; // Keycloak Server-URL
  static const String REALM = "movie-app";  
  static const String CLIENT = "movie-app-client-frontend";
  static const String REDIRECT_URI = "https://cinecritique.mi.hdm-stuttgart.de";
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
      var issuer = await Issuer.discover(
          Uri.parse('${kc_params.URL}/realms/${kc_params.REALM}'));
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
      var issuer = await Issuer.discover(
          Uri.parse('${kc_params.URL}/realms/${kc_params.REALM}'));
      _client = Client(issuer, kc_params.CLIENT);

      // IMPORTANT: This constructor (with urlLauncher & redirectUrl)
      // is only in openid_client_browser.dart
      _authenticator = Authenticator(
        _client,
        scopes: kc_params.SCOPESL,
        urlLauncher: (String url) async {
          window.location.href = url;  // Manual redirect
        },
        redirectUrl: Uri.parse(kc_params.REDIRECT_URI),
      );

      // Redirect to Keycloak login
      _authenticator.authorize();
    } catch (e) {
      print('Fehler beim Login: $e');
    }
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
